# Java 2D Game Development Roadmap

## Zielsetzung

Langfristiges Ziel:

- Galaga
- Pac-Man
- Dune II
- Settlers
- Pharaoh / Akhenaten

in Java zu entwickeln und dabei eine saubere, wartbare Architektur aufzubauen.

---

# Vergleich der Alternativen

## Engine Alpha

### Vorteile

- Sehr einfacher Einstieg
- Deutsche Dokumentation
- Schnelle Erfolgserlebnisse
- Für Schüler und Einsteiger konzipiert

### Nachteile

- Kleine Community
- Wenige größere Projekte
- Kaum Beispiele für RTS- oder Simulationsspiele
- Man wächst relativ schnell heraus

### Geeignet für

- Snake
- Pong
- Pac-Man
- Asteroids
- Lernprojekte

### Fazit

Sehr gute Lernumgebung, aber vermutlich zu limitiert für langfristige Projekte wie Dune II oder Akhenaten.

---

## FXGL

### Vorteile

- Moderne JavaFX-Basis
- Entity-System
- Animationen
- Kollisionen
- Gute Produktivität

### Nachteile

- Kleinere Community als LibGDX
- Weniger Beispiele für Strategie- und Aufbauspiele

### Geeignet für

- Galaga
- Pac-Man
- Bomberman
- Tower Defense
- Action-Spiele

### Fazit

Ideal für kleinere bis mittlere 2D-Spiele.

---

## LibGDX

### Vorteile

- Größte Java-Spieleplattform
- Sehr gute Performance
- Asset-Management
- Kamerasystem
- Tilemap-Unterstützung
- Audio
- Große Community

### Nachteile

- Höhere Lernkurve
- Mehr Infrastruktur

### Geeignet für

- Dune II
- Command & Conquer
- Settlers
- Transport Tycoon
- Pharaoh
- Akhenaten

### Fazit

Beste Wahl für ernsthafte Java-Spieleprojekte.

---

## jMonkeyEngine

### Vorteile

- Vollwertige Game Engine
- 3D
- Physik
- Terrain
- Beleuchtung

### Nachteile

- Für klassische 2D-Spiele überdimensioniert

### Geeignet für

- 3D RPGs
- 3D RTS
- Sandbox-Spiele

### Fazit

Für Akhenaten-artige 2D-Spiele unnötig komplex.

---

## LWJGL

### Vorteile

- Maximale Kontrolle
- Maximale Performance
- Direkter Zugriff auf OpenGL/Vulkan

### Nachteile

- Sehr niedrige Abstraktionsebene
- Praktisch alles muss selbst entwickelt werden

### Geeignet für

- Eigene Game Engine entwickeln
- Grafikprogrammierung lernen

### Fazit

Ideal wenn das Ziel die Engine selbst ist und nicht das Spiel.

---

# Empfehlung

Für einen erfahrenen Softwareentwickler:

1. Eigenen kleinen Engine-Kern auf Swing aufbauen
2. Galaga erstellen
3. Pac-Man erstellen
4. Dune-II-Prototyp erstellen
5. Entscheiden, ob später auf LibGDX migriert werden soll

---

# Architektur einer eigenen Swing-Engine

## Architekturübersicht

```text
engine
├── core
├── rendering
├── input
├── scene
├── assets
├── entities
├── collision
├── tilemap
├── audio
├── events
└── ui

game
├── scenes
├── entities
├── systems
└── resources
```

---

# Phase 1: Minimal Engine

## Core

```text
GameLoop
GameEngine
Timing
FPS Counter
```

### Aufgaben

- Starten
- Stoppen
- Update-Zyklen
- Render-Zyklen

---

## Rendering

```text
Renderer
Sprite
Animation
```

API-Idee:

```java
renderer.draw(sprite, x, y);
```

---

## Input

Abstraktion für:

```java
input.isKeyDown(Key.LEFT);
input.wasPressed(Key.SPACE);
```

Statt direkter Swing-Listener.

---

## AssetManager

```java
assets.getImage("player");
assets.getSound("explosion");
```

---

## SceneManager

```text
MainMenu
GameScene
PauseScene
GameOverScene
```

Interface:

```java
interface Scene {
    void init();
    void update(double delta);
    void render(Renderer r);
}
```

---

# Erstes Spiel

## Pong

Lernziele:

- Game Loop
- Rendering
- Input
- Szenen

---

# Phase 2

## Entities

```text
Entity
Player
Enemy
Bullet
```

---

## Collision

```text
Collider
CollisionManager
```

---

## Animation

Sprite-Animationen.

---

# Zweites Spiel

## Galaga

Lernziele:

- Objektverwaltung
- Kollisionen
- Animationen
- Sound

---

# Phase 3

## Kamera

```java
camera.setPosition(x, y);
camera.setZoom(1.5);
```

---

## Tilemap

```text
Tile
TileLayer
TileMap
```

---

## Pathfinding

A*

```text
Grid
Nodes
Path
```

---

# Drittes Spiel

## Pac-Man

Lernziele:

- Tilemaps
- KI
- Wegfindung

---

## Bomberman

Lernziele:

- Grid-Systeme
- Kettenreaktionen
- Mehrere Gegner

---

# Phase 4

## RTS-Erweiterungen

### Auswahlsystem

```text
Einheiten markieren
Mehrfachauswahl
```

### Weltkoordinaten

```text
Bildschirm -> Welt
Welt -> Bildschirm
```

### Scrollende Karte

```text
Kamerabewegung
```

---

# Viertes Spiel

## Dune II

Lernziele:

- Ressourcen
- Gebäude
- Einheiten
- KI
- Karten

---

# Phase 5

## Wirtschaftssystem

```text
Produktion
Lager
Transport
Verbrauch
```

---

## Event-System

```text
BuildingCreated
EnemyKilled
UnitSelected
```

---

## Savegames

JSON mit Jackson.

---

# Fünftes Spiel

## Settlers Lite

Lernziele:

- Produktionsketten
- Transporte
- Lagerhäuser
- Arbeiterlogik

---

# Phase 6

## City Builder

Systeme:

```text
Einwohner
Wohnhäuser
Arbeitsplätze
Nahrungsmittel
Handel
Steuern
```

---

# Endziel

## Pharaoh / Akhenaten

Benötigte Systeme:

```text
Tile Map
Kamera
Pathfinding
Produktionsketten
Transportlogik
Gebäude
Bevölkerung
Handel
Speichersystem
KI
```

---

# Zusammenfassung

Für einen Architekten und Entwickler mit Erfahrung in:

- Java
- Spring
- Angular
- Datenmodellierung

ist vermutlich der interessanteste Weg:

```text
Eigene Swing Engine
    ↓
Pong
    ↓
Galaga
    ↓
Pac-Man
    ↓
Dune II
    ↓
Settlers Lite
    ↓
Akhenaten
```

Dadurch lernt man sowohl die Spieleentwicklung als auch den Aufbau einer eigenen Engine und vermeidet es, sich zu früh an ein Framework zu binden.