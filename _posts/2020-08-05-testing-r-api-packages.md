---
layout: post
title: Testing R API Packages
categories: ["post"]
tags: ["software", "r", "github", "testing"]
---

I recently needed to test an [R package](https://github.com/nceas/rt) at [work](https://nceas.ucsb.edu) destined for [CRAN](https://cran.r-project.org/) that wraps an [API](https://bestpractical.com/request-tracker) and ran into a situation where:

1. I wanted only _unit_ tests to run when CRAN checks the package. A package with tests that run on CRAN and depend on web services such as APIs are bound to cause your package to fail CRAN's checks eventually which is a pain for both CRAN and you.
2. I wanted to check the package across a variety of platforms and R versions in a typical build matrix fashion.
3. I wanted to run a full _integration_ test suite somewhere other than my machine in order to ensure the integration tests work in a clean environment.

I settled on [GitHub Actions](https://github.com/features/actions) because it's integrated with GitHub itself (which is really nice) and there are already great resources such as [Jim Hester's talk](https://www.jimhester.com/talk/2020-rsc-github-actions/) and helpful utilities such as [usethis:use_github_actions()](https://usethis.r-lib.org/reference/github_actions.html) which makes it easy to get started.

The setup requires creating two GitHub Actions [workflows](http://web.archive.org/web/20200804113550/https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
:

1. One that runs `R CMD CHECK` across a build matrix of platforms and R versions to ensure the package works for others. This runs just _unit_ tests (i.e., those that don't depend on external access to an API).
2. Another that runs the full _integration_ test suite. This will use a [Docker](https://docker.com) container to spin up a fresh instance of the API I'm testing which is super easy with GitHub Actions.

Before setting up both workflows, I needed a way to skip a test if it's an integration test (i.e., depended on having access to the API).
I use `testthat` for my tests so I defined a helper in `./tests/setup-rt.R` (`rt` is my package name here) which makes my helper available to all tests:

```r
# Skip helper to control whether integration tests are run or not
skip_unless_integration <- function() {
  if (Sys.getenv("RT_INTEGRATION") != TRUE) {
    skip("Skipping integration test. Set RT_INTEGRATION to TRUE to run all tests.")
  }
}
```

This is the basis for a convention in my package where the full test suite is only run when the environmental variable `RT_INTEGRATION` is set to `TRUE` which I can control with GitHub Actions. With this setup, any test which requires access to the API gets skipped both on CRAN and when running the test suite locally when I prepend the following two lines to a test:

```r
test_that("we can get properties of a ticket", {
  testthat::skip_on_cran()
  skip_unless_integration()

  # The rest of the test
})
```

With this test helper and `testthat::skip_on_cran()`, I can control which tests are run on CRAN and which tests are run when I have GitHub Actions run the full test suite depending on whether I include both, one, or none of them.

Now we need to pair this with the two workflows I mentioned above.
These go in a `.github` folder at the top level of the package:

```
.github
└── workflows
    ├── ci.yml      # Build matrix
    └── tests.yml   # Integration tests

1 directory, 2 files
```

The first, `ci.yml` is a workflow that effectively runs `R CMD CHECK` on a variety of platforms and R versions (a build matrix):

{% raw %}
```yml
on: [push, pull_request]

name: CI

jobs:
  CI:
    runs-on: ${{ matrix.config.os }}

    strategy:
      fail-fast: false
      matrix:
        config:
          - { os: windows-latest, r: "3.6", args: "--no-manual" }
          - { os: windows-latest, r: "4.0", args: "--no-manual" }
          - { os: macOS-latest, r: "3.6" }
          - { os: macOS-latest, r: "4.0" }
          - { os: macOS-latest, r: "devel", args: "--no-manual" }
          - { os: ubuntu-18.04, r: "3.5", args: "--no-manual" }
          - { os: ubuntu-18.04, r: "3.6", args: "--no-manual" }
          - { os: ubuntu-18.04, r: "4.0", args: "--no-manual" }
    env:
      R_REMOTES_NO_ERRORS_FROM_WARNINGS: true

    steps:
      - uses: actions/checkout@v1

      - uses: r-lib/actions/setup-r@master
        with:
          r-version: ${{ matrix.config.r }}

      - uses: r-lib/actions/setup-pandoc@master

      - uses: r-lib/actions/setup-tinytex@master
        if: contains(matrix.config.args, 'no-manual') == false

      - name: Cache R packages
        uses: actions/cache@v1
        if: runner.os != 'Windows'
        with:
          path: ${{ env.R_LIBS_USER }}
          key: ${{ runner.os }}-r-${{ matrix.config.r }}-${{ hashFiles('**/DESCRIPTION') }}

      - name: Install system dependencies
        if: runner.os == 'Linux'
        env:
          RHUB_PLATFORM: linux-x86_64-ubuntu-gcc
        run: |
          Rscript -e "install.packages('remotes')" -e "remotes::install_github('r-hub/sysreqs')"
          sysreqs=$(Rscript -e "cat(sysreqs::sysreq_commands('DESCRIPTION'))")
          sudo -s eval "$sysreqs"

      - name: Install dependencies
        run: |
          install.packages("remotes")
          remotes::install_deps(dependencies = TRUE)
          remotes::install_cran('rcmdcheck')
        shell: Rscript {0}

      - name: Check
        run: Rscript -e "rcmdcheck::rcmdcheck(args = '${{ matrix.config.args }}', error_on = 'warning', check_dir = 'check')"

      - name: Upload check results
        if: failure()
        uses: actions/upload-artifact@master
        with:
          name: ${{ runner.os }}-r${{ matrix.config.r }}-results
          path: check
```
{% endraw %}
The second, `tests.yml` runs the full test suite, which includes integration tests:

{% raw %}
```yml
on: [push, pull_request]

name: Tests

jobs:
  CI:
    services:
      rt:
        image: netsandbox/request-tracker
        ports:
          - 80:80

    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v1

      - uses: r-lib/actions/setup-r@master

      - name: Cache R packages
        uses: actions/cache@v1
        with:
          path: ${{ env.R_LIBS_USER }}
          key: ${{ hashFiles('**/DESCRIPTION') }}

      - name: Install system dependencies
        env:
          RHUB_PLATFORM: linux-x86_64-ubuntu-gcc
        run: |
          Rscript -e "install.packages('remotes')" -e "remotes::install_github('r-hub/sysreqs')"
          sysreqs=$(Rscript -e "cat(sysreqs::sysreq_commands('DESCRIPTION'))")
          sudo -s eval "$sysreqs"

      - name: Install dependencies
        run: |
          install.packages("remotes")
          remotes::install_deps(dependencies = TRUE)
          remotes::install_cran('rcmdcheck')
        shell: Rscript {0}

      - name: Check
        run: Rscript -e "rcmdcheck::rcmdcheck(args = \"--no-manual\", error_on = 'warning', check_dir = 'check')"

      - name: Upload check results
        if: failure()
        uses: actions/upload-artifact@master
        with:
          name: results
          path: check
```
{% endraw %}

Hopefully this pattern is useful to others.
So far, I've found this setup works well and the hosting all of this on GitHub Actions also works well.
