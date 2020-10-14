---
layout: page
style: projects
title: Projects
---

I work on open source software projects in my spare time and put together a list of the more noteworthy (to me at least) ones here. See my [GitHub](https://github.com/amoeba) profile for these -- and other -- projects.

- **Yukon Chinook run timing forecasting**
  [2012 → Current]
  I run a collaborative team to forecast the run timing of the Yukon River (Alaska) Chinook Salmon stock. Pre-season forecasts come out in April and May, and in-season forecast updates get made daily in June and through mid-July. Past years' forecasts: [2019](https://github.com/amoeba/2019-yukon-forecasting), [2018](https://github.com/amoeba/2018-yukon-forecasting), [2015](https://github.com/amoeba/2017-yukon-forecasting), [2016](https://github.com/amoeba/2016-yukon-forecasting), [2015](https://github.com/amoeba/yukon-2015-april).

  ![graph from yukon chinook forecasting project showing two curves](/assets/projects/yukon-chinook.png)

  <hr>


- **TreeStats** [2015 → Current]: Combination Ruby (website) and C# (Decal plugin) for Asheron's Call player tracking. _Yes, it's supposed to look like that :)_. [Website](https://treestats.net), Code: [Website](https://github.com/amoeba/treestats.net), [Plugin](https://github.com/amoeba/treestats).

  ![screenshot of treestats.net](/assets/projects/treestats.net.png)

  <hr>

- **hotline** [2019 → Current]: WIP Rubygem for the Hotline protocol. Currently only supports the Tracker Client portion of the protocol. [Code](https://github.com/amoeba/hotline).

<hr>

- **TownCrier** [2019]: [Decal](https://www.decaldev.com/) plugin for sending webhooks on to various services when certain ingame events happen. [Code](https://github.com/amoeba/towncrier)

  ![screenshot of a Discord message](/assets/projects/towncrier.png)

  <hr>

- **Overly-Detailed Asheron's Call Skill Planner (ODACCP)** [2017]: Similar to other character planners out there for Asheron's Call but _way_ more complicated (See: awesome). I mainly started this to learn [Vue](https://vuejs.org/) but it's turned out pretty usable. Sorry for the name and the overly Spartan interface. Hosted on [Zeit Now](https://zeit.co) with [Firebase](https://firebase.google.com/) for persisting shared profiles. I use this project as an advanced Hello World of sorts for learning frameworks like [React + MobX](https://github.com/amoeba/accharplanner-react-mobx), [choo](https://github.com/amoeba/accharplanner-choo), and [Svelte](https://github.com/amoeba/accharplanner-svelte). [Website](https://planner.treestats.net/), [Code](https://github.com/amoeba/accharplanner).

  ![screenshot of a planner.treestats.net](/assets/projects/planner.png)

  <hr>

- **DataNext** [2019]: [DataONE Search](https:/search.dataone.org) client written in [Next.js](https://nextjs.org). Mostly written to test out the React/Next.js waters but it's turning out pretty usable at this point. [Code](https://github.com/amoeba/datanext).

  <hr>

- **standardrb-action** [2019]: [GitHub Action](https://github.com/features/actions) for [Test Double](https://www.testdouble.com/)'s [standard](https://github.com/testdouble/standard). [Code](https://github.com/amoeba/standardrb-action).

  ![screenshot an annotation from standardrb-action](/assets/projects/standardrb-action.png)

  <hr>

### Past

- **DecalDev.com** [2020]: Website for [decaldev.com](https://www.decaldev.com/). Made the original version back in who knows when. Redone in 2020.
- **PhatACUtil** [2017]: Helper Decal plugin for testing and developing a private Asheron's Call server emulator (now defunct). [Code](https://github.com/amoeba/PhatACUtil).
- **upriver** (2015): R package for my M.S. Fisheries thesis on in-river migration modeling of salmon. [Paper](https://scholarworks.alaska.edu/bitstream/handle/11122/7304/Mecum_B_2016.pdf?sequence=1), [Code](https://github.com/amoeba/upriver).
- **rdftoweb** [2015]: Static site generator for RDF. Creates a series of static HTML pages from an RDF graph. I made this largely for my own purposes when I wanted to share RDF with others and didn't have a lightweight solution for it. [Code](https://github.com/amoeba/rdftoweb).
- **hltracker** [2015]: Simple Ruby script for querying [Hotline](https://en.wikipedia.org/wiki/Hotline_Communications) trackers. Eventually turned into the [hotline](https://github.com/amoeba/hotline) rubygem. [Code](https://github.com/amoeba/hltracker).
- **AutoDeShift** [2009]: World of Warcraft plugin made for my own use to automatically de-shapeshift when needed. [Code](https://github.com/amoeba/AutoDeShift).
- **receipt** [2009]: World of Warcraft plugin to show the net results of vendor transactions. [Code](https://github.com/amoeba/receipt).
- **DeadlyWatcher** [2009]: World of Warcraft plugin that shows the number of stacks of Deadly Poison your target. [Code](https://github.com/amoeba/deadlywatcher).
- **Alias** [2008]: Decal plugin for helping you keep track of your friend's many alts by putting a common name or alias next to their alts' names in chat. [Code](https://github.com/amoeba/alias).

## Other Projects

These are projects I worked on that never made it out of development for one reason or another.

- **LoLtistics** [2010]

  An online match history viewer for [League of Legends](https://leagueoflegends.com) (similar to [LeagueSpy](https://leaguespy.net)). This is from way back when the LoL client wrote game logs to disk and players had to upload those logs to websites (like Loltistics) to share their games.
  It looks like, since then, Riot Games has produced an API which makes this all a lot better.
  [Code](https://github.com/amoeba/loltistics).

  _What didn't work?_ It was time consuming and felt like a losing battle to keep updating the log file parsing routine when the LoL client updated.

- **Pacific Northwest Marine Field Guides** [2010]

  Ruby (Rails) web application for creating customized field guides of marine species in the Salish Sea area but written for really any area and type of organism. WWU students would fill in basic life history information about vaious species as part of their classwork and then other scientists or people (i.e., a K-12 educator) could create printable (PDF) field guides of the species they were interested in. I did this work as part of my undergraduate research at Western Washington University. [Code](https://github.com/amoeba/marine_field_guides).

  _What didn't work?_ In 2010, hosting Ruby on Rails applications was a bit of a pain. To add to that difficulty, our campus infrastructure ran on FreeBSD (which I didn't know when we started the project). It turned out that our sysadmins weren't willing to let us run a Ruby web app so the code just ended up sitting there because we had a hard requirement to run it on campus infrastructure. Lesson learned: Get to deploying to production early and often. We would've been better off writing the application in PHP because our sysadmins wouldn't have had any issues with that.
