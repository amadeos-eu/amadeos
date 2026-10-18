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

Ideal wenn das Ziel die Engine selbst ist und nicht