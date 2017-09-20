# Colorful Critter

This is a game I did for [eevee](http://eev.ee)'s [Strawberry Jam](http://itch.io/jam/strawberry-jam). It was built with [LÖVE](http://love2d.org). There is a further explanation of the why, what, and how in the `whitepaper` directory (I recommend playing the game before ruining the fun, however).

To run it, point your LÖVE interpreter at the `src` directory. You can also build a standalone version; simply run `make` and the Makefile will do all the rest (including fetching LÖVE, if necessary). The build results will go into `build/`. My Makefile also provides a simple CD publishing pipeline for itch.io. I only provide it as an example; obviously I would prefer if you not publish my game to your itch site (but feel free to [support me on itch](http://itch.io/fluffy)).

This game is &copy;2017 j "fluffy" shagam; please see `LICENSE` for further copyright terms.

## Building on Android

You will need to install [NDK R14b](https://developer.android.com/ndk/downloads/older_releases.html) and override the `ndk.dir` setting in the `local.properties` file to point to it. This is a work-in-progress.