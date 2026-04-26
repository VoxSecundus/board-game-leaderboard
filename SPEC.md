# board-game-leader Product Specification

## 1. Goal

The goal of this project is to create an application that I can use to track board games played between me and my friend(s). We play lots of board games, and currently, for each session, we track: who played; what we played; the date that we played; and who won. We are using the notes app in someone's phone, and I would like a more structured way of doing so.

## 2. Functional requirements
- I need to be able to add players to the application. Players should have a display name and a profile picture.
- I need authentication set up. Every time you visit the application, the user should be asked for a password. We do *not* need user-based authentication; just a password to access the application. If the admin password ever needs to be reset, I will do so manually from the application console (or by editing the database).
- I need to be able to add games to the application. We should store, from the board game: the name; the box art; and a hyperlink to the boardgamegeek listing. I should be able to enter each of these details manually. In the future, we may consider being able to paste a URL to a boardgamegeek listing for a game, to fill in the info automatically.
- I need to be able to add locations to the application. These recognise where the game was played. Each location only needs a name, although being able to assign a map pin with co-ordinates to a location would be cool, too. A later improvement (not one for the initial application draft) could be to render an interactive map with all played locations on it.
- I need to be able to record "plays" of a game. Each "play" will specify a board game that is in the application database, who played, the date on which it was played (optional), the location it was played in (optional), who won (optional), and the score (optional).
-  We should have an audit trail for when plays are recorded or edited. I don't mind if this is a separate record in the database or something that is inferred from existing data.
- When I view a game, I want to see a history of plays for that game.
- When I view a player, I want to see a history of plays for that player.
- I want to be able to compare two players to see their record against each other, with an optional filter for specific games (plural!).

## 3. User Experience

- The application should have a toolbar at the top of the page to act as a main menu.
- Each page of the application containing a enumerated data should be viewable as a grid or a row-based table.
- Tables should be sortable by any attribute that makes sense by clicking the sortable column header in the table.
- When viewing a player's page, each row/grid cell containing a play should have a soft red/green background, depending on the outcome of the game.
- I want a minimal interface, with an optional dark mode.
- We don't need extra flashy animations or transitions on page change. However, we may consider it in the future.
- While this is a single page application, we should support breadcrumbs for page navigation.
- Every instance of a player's name should have a hyperlink to their profile page.
- (Almost) every instance of a player's name should have a tiny thumbnail of their profile picture next to it. Consider for yourself where this might not be appropriate.
- Every instance of a game's name should have a hyperlink to the game's page.

## 4. Technical Specifications

- We will be using Ruby on Rails for the tech stack.
- I would like to use Hotwire instead of maintaining a separate JavaScript frontend application.
- I want to use SQLite for any data that needs to be stored server-side.
- The database should be stored in an encrypted format. The environment *must* provide a secret key as an environment variable.
- The application should be accessible from a web browser, primarily. It will be hosted on my home server, and, initially, will only be reachable from my home network.
- The server that will be used for hosting the application is light on resources. It is vital that the CPU/memory footprint of the server is minimal.
- I need to be able to run the application in Docker.
- We should be taking a test-driven development approach, testing both the backend behaviour and the web interface behaviour.
- Board Game Geek has a public XML API available, with a spec at (`https://boardgamegeek.com/wiki/page/BGG_XML_API2`)
- When possible, all requests should be made by the server, with the results cached.
- The environment *must* provide an authorization token to use when making XML API requests.

## 5. Agent tips

- We need to write a CLAUDE.md file for the application.
- We need to write a README.md file for the application.
- I am working with (potentially) limited amounts of Claude credits. The goal of this plan should be to split the product spec into meaningful phases, so that we can complete the application in chunks without running out of context or credits mid-phase. After each phase, I will test what has been implemented myself.
- Please be as scrutinous as possible. If you have any doubts about an implementation detail, you must ask. If there are things missing from this plan that you think ought to be included/considered in a (small) modern web application, mention them.

## 6. Glossary
- BGG: Board Game Geek (https://boardgamegeek.com/)
