---
layout: post
title: tibbles
categories: ["post"]
tags: ["r", "tidyverse", "tibble"]
---

Slack convo:

cboettig:

Is class(df) <- c("tbl", "data.frame") the correct / advisable way to offer 'opt-in' tibble-formatting of data.frames in a package?  (I.e. avoid a hard dep on tibble and let tidyverse users and base R users both get the print behavior they know and expect?)  Or is there a better / less hack-ish way to do this?  Does the above hack risk any adverse side-effects (e.g. compared to actual class coercion via as_tibble() ?
You're definitely not meant to do that. It's c("tbl_df", "tbl", "data.frame") anyhoo

Sam Albers  3 hours ago
I do this in the rsoi package but it does feel a bit dangerous because a user might depend on one type of behaviour (drop = FALSE comes to mind) which would be conditional upon a library being loaded. That could problematic at times.

Bryce Mecum  3 hours ago
I'm eager to know what others are doing. I did this in my last package and just wrapped each return value in a try_tibble function I wrote which coerces to a tibble if the package is installed and can be overridden with dots.

Michael Sumner  3 hours ago
https://twitter.com/noamross/status/1067853765389230080?s=19 just related
Noam RossNoam Ross @noamross
@JennyBryan @krlmlr Can we still cheat and do class(df) <- c("tbl_df", "tbl", "data.frame") to produce tibbles without any dependencies?
TwitterTwitter | Nov 28th, 2018
:+1:
1


Bryce Mecum  3 hours ago
(I'll note that I was able to keep tibble in Suggests with my method but it totally breaks reproducibility)
:+1:
1


Sam Albers  3 hours ago
Given so many people would have tibble installed anyways, maybe the active ‘as_tibble’ step might be better and not as big of a burden as a dep.

Carl Boettiger  2 hours ago
Thanks, but I'm with @noamross on this one in that I see having different print behavior depending on whether or not the library is loaded as a feature not a bug, but I'm willing to be convinced it is a bug...

Bryce Mecum  2 hours ago
R's built-in printing behavior is a bug IMHO

Carl Boettiger  2 hours ago
The drop = FALSE is an interesting example -- but I think it's okay in that if a user saw the tibble-print behavior (because they had tibble loaded) they'd also get the tibble-drop=FALSE behavior?

Carl Boettiger  2 hours ago
I personally agree that R's default behavior for print.data.frame and it's default behavior of drop = TRUE on [] operations are bad choices, but I'm not quite sure that means as a package author I should take the liberty to never return a data.frame that isn't a tibble

Rich FitzJohn  1 minute ago
In stevedore, I provide a "data_frame" argument to the API constructor that lets users choose which "enhanced data frame" they want - https://richfitz.github.io/stevedore/reference/docker_client.html
richfitz.github.io
Create docker client — docker_client
Create a docker client object, which allows you to interact with docker from R. The object has several methods that allow interaction with the docker daemon (for this object they are all "system" commands) and collections, which contains further methods. The client is structured similarly to the docker command line client, such that docker container create <args> in the command line becomes docker$container$create(...) in R (if the client is called R).
