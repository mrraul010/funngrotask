# Funngro Mobile Engineering Assessment – Written Answers

## PART 1: Code Review of EarningsScreen

### Task 1 – Problems ordered by how bad they are for users

**1. fetchEarnings and walletUpdates.listen() are inside build()**

This is the biggest problem.

build() runs a lot — setState, keyboard opening, parent rebuilds, etc. Every time it runs, it fires a new network call and creates a new StreamSubscription. When the future finishes and calls setState, it rebuilds again and the cycle continues. On a low-end phone this will just keep allocating memory until the app crashes. You’ll also see the same earnings getting duplicated at the top of the list and the UI becomes completely unresponsive.

Move the fetch and the stream subscription out of build. Put them in initState or (better) in the Bloc. Keep a reference to the subscription so you can cancel it later. Side effects do not belong in build.

**2. Building ~3000 items with SingleChildScrollView + Column and calling formatCurrency inside the map**

Opening the screen or receiving a wallet update freezes the UI for several seconds. ANR dialogs start showing up.

SingleChildScrollView + Column builds every single tile immediately. On top of that, formatCurrency is running 3000 times on the main thread during build. That’s a lot of work.

Use ListView.builder instead. If the tiles have fixed height, give it an itemExtent. Format the currency once when you convert the API data into view models, not inside the build method.

**3. StreamSubscription never cancelled + setState / Navigator after dispose**

If the user leaves the screen while a request is still going, or if a wallet update comes after the widget is gone, you get “setState() called after dispose()” and sometimes try to push with a dead context. The subscription also keeps the State in memory.

Cancel the subscription in dispose (or Bloc.close). Always check if (!mounted) return; before calling setState or using the context after an await. Navigation is cleaner if you move it to a BlocListener.

**4. loading starts as false and there’s no error handling**

First frame is just an empty screen. If the network fails, nothing happens — no error, no retry.

Start with loading = true (or the equivalent in your state). Wrap the futures in try/catch and show proper loading / error / empty states.

**5. onTap isn’t protected against rapid taps**

On a slow connection, tapping the same tile a few times fires multiple fetchDetail calls and pushes multiple DetailScreens.

Track which id is currently loading and ignore further taps, or cache the detail once you have it.

### Task 3 – Conventions for 60+ screens

A few simple rules would prevent most of these issues from spreading:

- No API calls or stream.listen() inside build. Keep side effects in Blocs/Cubits. Enforce it with custom_lint + CI.
- All list screens should use a shared paginated list widget that uses ListView.builder (and itemExtent where possible). Don’t allow SingleChildScrollView + Column for dynamic lists.
- Do expensive formatting (currency, dates, etc.) once when creating the view model, never in build.
- For high-traffic screens, profile on a low-end device in profile mode before merging. Look at frame times and check for leaked subscriptions.

That’s enough to keep things under control.

## PART 3: Production Scenario (v6.4.0 Crashlytics Spike)

### 1. Message to founder

Hey Anik, can we hold the v6.4.0 rollout at 20% for now? Don’t push it to 50% and don’t kill it completely yet. I need about 90 minutes to check whether this PlatformException is limited to certain Android versions or OEMs, or if something changed in the lifecycle handling in this release. If I can’t find a quick remote workaround within a couple of hours, we’ll drop the 20% cohort and ship a 6.4.1.

### 2. Day-1 investigation plan

**First things I’d check in Crashlytics:**

- The exact error code and native stack. Is it an App Open Ad or Interstitial trying to show on resume before the Activity is ready?
- Breadcrumbs / custom keys right before the crash — what screen the user was on, and whether they were coming back from UPI, browser, or a permission dialog.

**Filters I’d look at:**

- Android version (especially 14 and 15 — lifecycle timing got stricter)
- Low-RAM devices and specific OEMs (Xiaomi, Realme, Samsung) — they kill activities more aggressively
- The actual diff of v6.4.0: targetSdk, compileSdk, AGP, Flutter version, any changes to MainActivity or the AppLifecycleState listener

**How I’d decide:**

- Drop to 0% if crash-free users keep dropping, if the crash is looping and users can’t open the app, or if we still don’t know what’s going on after ~2 hours.
- Stay at 20% while investigating or while testing a remote kill switch.
- Fix forward once we can reliably reproduce it (mounted check + try/catch around the ad show, maybe a small delay).

I wish we already had a Remote Config flag around the resume ad logic, plus a try/catch on every native ad call. For any third-party SDK that runs on lifecycle events, that kind of kill switch is worth having.

## Assumptions & questions

- walletUpdates — the original code always inserts at index 0. I assumed the stream can send both new items and updates to existing ones, so I deduped by id. Does it only ever send brand-new transactions, or can it also send updates?
- fetchDetail — original code mutates e.detail. I cached it assuming details don’t change during a session. Is that safe, or can details change often enough that we should always re-fetch?
- Pagination — the mock returns 20 items then empty. I’m treating an empty/short page as the end. Does the real API give us a hasMore or totalPages field, or do we just rely on empty responses?