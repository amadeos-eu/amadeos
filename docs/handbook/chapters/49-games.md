# 49. Games

amadeOS comes with **fourteen games**, all in the Games drawer of the Front Panel. They are written for amadeOS with its own game engine, have no advertising, no accounts and no purchases, and need no network.

## What all games share

- **Best scores and times**, ten for each game (*Game → High Scores…* in Mines and Solitaire).
- Every game speaks the five languages of amadeOS.

The twelve action and strategy games also share:

| Key | What it does |
|---|---|
| ++enter++ or ++space++ | Starts from the title screen |
| ++p++ or ++esc++ | Pause. Leaving the window pauses too. |
| ++f11++ | Full screen and back |
| ++f12++ | Shows how long each frame takes, for the curious |

- **Title screen.** It names the keys, and in the arcade games the computer plays until you start, so you can watch how the game goes.
- ***Game → Graphics*** chooses how the picture reaches the screen: **Direct**, sharp at the full size of the screen, or **Pixels**, at 640 × 400 enlarged with square pixels, as on the home computers of the 1980s. If a game runs jerkily on an old computer, try *Pixels*.
- ***Game → Sound*** switches sound effects and music off.

Mines and Solitaire take the colours of your palette in Settings; ++f2++ starts a new game in Mines.

## Thinking and cards

### Mines

![Mines](images/49/mines.jpg){ align=right width="180" }

Find all mines on the field without stepping on one. **Left click** opens a cell; a number says how many mines touch it. **Right click** sets a flag. **Middle click** on a number opens its neighbours once enough flags surround it. The first click is always safe. Three sizes in the *Game* menu, from *Beginner* (9 × 9, 10 mines) to *Expert* (30 × 16, 99 mines).

### Solitaire

![Solitaire](images/49/solitaire.jpg){ align=right width="240" }

Klondike, the classic patience. Build the four piles at the top right from ace to king in one suit; in the seven columns cards go down in alternating colours. **Click the stock** to turn a card, or three with *Game → Draw Three*. **Drag** cards, **double-click** to send a card home. Undo with ++ctrl+z++ as far back as you like.

<div style="clear: both"></div>

## Arcade classics

| | Game | What you do |
|---|---|---|
| ![](images/49/paddle.jpg){ width="200" } | **Paddle** | The ball game for two paddles: against the computer with the arrow keys, or two players on one keyboard (W and S against the arrows). The first to 11 wins. |
| ![](images/49/bricks.jpg){ width="200" } | **Bricks** | Break the wall with ball and paddle, by mouse or keys. Silver bricks take two hits, gold ones never break. Five levels. |
| ![](images/49/snake.jpg){ width="200" } | **Snake** | Steer the snake to the apples with the arrow keys; it grows longer and faster. Never bite the wall or yourself. |
| ![](images/49/rocks.jpg){ width="200" } | **Rocks** | Turn, thrust and shoot through waves of rocks that break into smaller ones. ++arrow-down++ jumps into hyperspace. |
| ![](images/49/swarm.jpg){ width="200" } | **Swarm** | Insects fly in, take their places and dive at your fighter. Every third stage is a challenge with a bonus. |
| ![](images/49/maze.jpg){ width="200" } | **Maze** | Eat every dot while four ghosts hunt you, each in its own way. After an energizer, you hunt them. |
| ![](images/49/blast.jpg){ width="200" } | **Blast** | Up to four players lay bombs among crates, on the keyboard and on gamepads; the computer fills the empty seats. The last one standing wins. |
| ![](images/49/jump.jpg){ width="200" } | **Jump** | Run and jump through a meadow, caves and the clouds, take the coins, land on beetles and birds, reach the red flag. Gamepads work too. |

## Strategy and building

| | Game | What you do |
|---|---|---|
| ![](images/49/towers.jpg){ width="200" } | **Towers** | Orcs, wolves and trolls march on your castle. Build archers, cannons and frost towers beside the road, or on open ground, where your towers make the maze. |
| ![](images/49/sands.jpg){ width="200" } | **Sands** | Real-time strategy on a desert planet: harvest crystals, build a base, wind turbines and factories, and drive out the enemy with trikes, tanks and rocket launchers. Three missions. |
| ![](images/49/colony.jpg){ width="200" } | **Colony** | Lay out houses and roads in a green valley; carriers bring the goods from flag to flag. Woodcutters, a sawmill, farms, a windmill and a bakery, sheep and a weaver make the settlement grow. |
| ![](images/49/town.jpg){ width="200" } | **Town** | A city in isometric view: roads, zones for homes, shops and industry, power and water. The town grows by itself where people want to live and work. |

In the strategy games, ++f5++ saves and ++f9++ loads, and a mission opens when the one before it is won.

!!! tip "Your own keys"
    Most action games let you change their keys in a small settings file, such as `~/.config/amadeos/snake/snake.properties`. The Game Developer's Handbook in the Help drawer has the details.

The games are in the spirit of the classics of the 1980s and 1990s, drawn anew, and built so that each one can be read and learned from: the **Game Developer's Handbook** in the Help drawer explains them chapter by chapter.

??? hood "Under the hood"
    Every game is a package of its own, `amade-mines-game` to `amade-town-game`, and all are installed by default. They are built on *amade-game-engine*, a 2D game engine in Java. The best scores are in `~/.local/share/amadeos/games/<game>/`, the settings in `~/.config/amadeos/<game>/`.
