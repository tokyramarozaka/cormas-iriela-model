# IRIELA

IRIELA is an agent-based model (ABM) built with **Cormas** on **Pharo**, simulating a village of resource-collecting agents. The agents' behaviors are constrained by a configurable set of social norms — obligations, prohibitions, and permissions — built on top of the [cormas-norms](https://github.com/cormas/cormas-norms) project.

It is designed to explore how the presence, absence, or combination of norms affects collective outcomes such as resource sustainability and food security. Under the hood it uses **Metaproxies** to intercept the agents' decision process and integrate norms into their behavior.

### At a Glance

| | |
|---|---|
| **Agents** | Villagers that inhabit the grid, each tracking its own `daysWithoutFood` counter. |
| **Behaviors** | Each step, an agent either **moves** randomly to another cell, or **harvests** the resource on its current cell (wood or fish), the cell's cover (if any) can hold norms that would restrict activities on it. |
| **Resources** | **Wood** and **fish**, scattered across the grid; an agent can only collect what is present on the cell it currently occupies. Once an agent has fish and has wood, its `daysWithoutFood` does not increment at the cost of 1 wood|
| **Norms implemented** | `IMProhibitionToFishWithoutLicense` — fishing without a license gets the catch confiscated and a fine. `IMObligationToHaveWood` — with no wood on hand, a caught fish can't be cooked and goes to waste. Each is independently toggleable; permissions can be added to carve out exceptions to either. |

## Table of Contents

- [Overview](#overview)
  - [At a Glance](#at-a-glance)
- [Requirements](#requirements)
- [Installation](#installation)
- [Core Concepts](#core-concepts)
  - [The Grid and Cell Covers](#the-grid-and-cell-covers)
  - [Resources](#resources)
  - [Agents (Villagers)](#agents-villagers)
  - [Norms: Obligations, Prohibitions, Permissions](#norms-obligations-prohibitions-permissions)
- [Simulation Step Cycle](#simulation-step-cycle)
- [Food Security Indicator: `daysWithoutFood`](#food-security-indicator-dayswithoutfood)
- [Model Parameters](#model-parameters)
- [Running the Model](#running-the-model)
- [Visualization Legend](#visualization-legend)
- [Extending the Model](#extending-the-model)

## Overview

IRIELA places a population of villager agents on a rectangular grid representing their territory. Each step, agents either move randomly across the grid or attempt to harvest resources (wood or fish) from the cell they occupy. Some cells carry a special **cover** (office, sacred or protected) that constrains what agents are allowed to do there.

On top of this base mechanic, the model layers a **normative system**: a configurable set of obligations, prohibitions, and permissions that agents may (or may not) comply with. Norms can be individually switched on or off before a run, making IRIELA a tool for comparing "with norms" vs. "without norms" scenarios and studying their effect on resource use and agent well-being.

## Requirements

- [Pharo](https://pharo.org/) (matching the version required by your Cormas installation)
- [Cormas](https://www.cormas.org/) (Common-pool Resources and Multi-Agent Systems) framework loaded into the Pharo image
- [Cormas-norms](https://github.com/cormas/cormas-norms) — a framework for representing norms in Cormas
- The IRIELA model package loaded on top of Cormas

## Installation

IRIELA depends on **Cormas** and the **Cormas-Norms** plugin. Both can be loaded into a Pharo image via Metacello, from a Playground/Workspace:

```st
"First install Cormas"
Metacello new
    repository: 'github://cormas/cormas';
    baseline: 'Cormas';
    load.

"Then install the norms plugin"
Metacello new
    repository: 'github://cormas/cormas-norms:main';
    baseline: 'CormasNorms';
    load.
```

Once both are loaded, load the IRIELA model package on top of them the same way.

## Core Concepts

### The Grid and Cell Covers

The environment is a grid of `numberOfRows` × `numberOfColumns` cells. Every cell may optionally carry a **cover**, which changes how agents may interact with it:

| Cover | Description |
|---|---|
| **Office** | An administrative cell (e.g. where licenses can be delivered). |
| **Sacred** | A protected-by-tradition cell, typically off-limits for trespassing. |
| **Protected** | A cell under formal protection (e.g. a reserve), restricting resource extraction. |

Cells without a special cover are plain terrain that may still contain harvestable resources.

### Resources

Two resource types can be scattered across the grid:

- **Wood**: collected by agents and spent as **cooking fuel** — a fish can only be eaten (and satisfy hunger) if the agent has wood to cook it with.
- **Fish**: collected by agents to satisfy their food needs, but only once cooked. An uncooked fish spoils and is lost rather than carried over — it isn't a resource meant to be stockpiled.

An agent can only collect the resource(s) present on the cell it currently occupies.

### Agents (Villagers)

Villager agents populate the grid (`numberOfAgents`). Each step, an agent decides between two basic behaviors:

1. **Move** — relocate randomly to a neighboring/other cell on the grid.
2. **Harvest** — collect a resource (wood or fish) available on its current cell.

Which behavior an agent takes, and whether it is *allowed* to take it, depends on the cell's cover and on which norms are currently active.

### Norms: Obligations, Prohibitions, Permissions

IRIELA implements norms as toggleable rules that regulate agent behavior. Norms fall into three classical deontic categories:

- **Obligations**: things an agent *must* do.
- **Prohibitions**: things an agent *must not* do.
- **Permissions**: things an agent is explicitly *allowed* to do, typically used to carve out exceptions to a prohibition in a faster way.

#### `IMProhibitionToFishWithoutLicense`

Fishing requires a license, which can only be obtained by physically visiting an **office** cell. An agent without a valid license that goes ahead and fishes anyway is caught in violation:

- Its catch is **confiscated** — the fish is not added to its inventory.
- It pays a **wood fine** (`fineAmount`) as a penalty, deducted from whatever wood it's carrying (if it has less than `fineAmount`, it simply pays what it has).

A licensed agent fishes freely. A license lasts `licenseDuration` steps before it lapses, at which point the agent must return to an office cell to renew it or risk being fined again.

#### `IMObligationToHaveWood`

Villagers are expected to always keep some wood on hand — not as a stockpile, but as the fuel needed to cook whatever fish they catch. When an agent catches a fish:

- If it is carrying wood, it **spends 1 wood to cook the fish and eats it** — its food need is satisfied for the step.
- If it has **no wood**, the fish cannot be cooked. It spoils and is lost, and the agent effectively went hungry despite having caught something — a very "so close, yet so far" failure mode that makes wood scarcity bite even when fish are plentiful.

This is why the obligation matters even though wood is never directly eaten: an agent that neglects its wood supply undermines its own fishing effort.

Each norm can be **activated or deactivated independently** before running a simulation, via a checklist of "Model norms" in the interface:

This lets users run controlled comparisons — for instance, observing agent food security with and without the fishing-license prohibition in effect.

## Simulation Step Cycle

At every simulation step (tick), the following happens:

1. **Agent decision** — each agent chooses to either move randomly on the grid, attempt to collect a resource on its current cell, or (if standing on an office cell) obtain/renew its fishing license.
2. **Resource collection & norm checks** — if harvesting a fish, the model checks `IMProhibitionToFishWithoutLicense`: a licensed agent keeps the fish, an unlicensed one has it confiscated and pays a wood fine instead. Wood is simply collected if present.
3. **Cooking** — if the agent is holding a fish (legally caught this step), `IMObligationToHaveWood` is checked: with wood available, 1 wood is spent to cook and eat the fish; with none, the fish spoils and is lost uneaten.
4. **Food tracking update** — the model checks whether each agent actually ate a fish this step; if not, that agent's `daysWithoutFood` counter is incremented (see below).

## Food Security Indicator: `daysWithoutFood`

Each agent maintains a `daysWithoutFood` counter. Every step:

- If the agent **eats a fish** this step (i.e. it caught one legally *and* had wood to cook it with), `daysWithoutFood` is **reset to zero**.
- If the agent does not eat — whether because it caught no fish, had its catch confiscated for lacking a license, or had a fish spoil for lack of wood — `daysWithoutFood` is **incremented**.

This means the counter reflects failure at *any* point in the chain: no fishing opportunity, an unlicensed catch, or an uncooked meal all count the same way.

This counter serves as the model's core indicator of individual (and, aggregated, collective) food security, and is a natural output for comparing scenarios with different norm configurations.

## Model Parameters

Before launching a run, the following parameters can be configured from the **Parameters → Model** tab:

| Parameter | Description | Example value |
|---|---|---|
| `numberOfRows` | Number of rows in the grid | 5 |
| `numberOfColumns` | Number of columns in the grid | 5 |
| `numberOfAgents` | Number of villager agents | 5 |
| `numberOfFishes` | Number of fish resources placed on the grid | 2 |
| `numberOfWoods` | Number of wood resources placed on the grid | 2 |
| `numberOfOffices` | Number of "office" cover cells | 1 |
| `numberOfSacredCells` | Number of "sacred" cover cells | 3 |
| `numberOfProtectedCells` | Number of "protected" cover cells | 3 |
| `licenseDuration` | Number of steps a fishing license stays valid before it must be renewed at an office cell | 10 |
| `fineAmount` | Amount of wood confiscated as a fine when an agent fishes without a valid license | 1 |

The **Class** and **Selection** tabs (alongside **Model**) expose further Cormas-standard parameterization, such as class-level defaults and entity-selection options, following the usual Cormas simulation-configuration UI.

## Running the Model

1. Launch Pharo with Cormas, Cormas-Norms and the IRIELA package loaded.
2. Open the Cormas simulation environment and select the **IRIELA** model.
3. In the **Model norms** panel, check/uncheck the norms you want active for this run (e.g. `IMProhibitionToFishWithoutLicense`, `IMObligationToHaveWood`).
4. In the **Parameters** panel, set the grid size, agent count, resource counts, and cover-cell counts as desired.
5. Initialize the simulation to generate the grid, place resources/covers, and spawn agents.
6. Step through or run the simulation, observing agent movement, resource collection, and the evolution of each agent's `daysWithoutFood` counter.

## Visualization Legend

On the spatial grid view:

| Icon | Meaning |
|---|---|
| 🐟 (fish icon) | A cell containing a fish resource |
| 🌳 (tree icon) | A cell containing a wood resource |
| 🔵 (blue figure) | A villager agent currently on that cell |
| Plain green cell | Empty terrain (no resource, no agent) |

Cell covers (office, sacred, protected) are configured via parameters and affect what agents can legally do on those cells, even though they may not always be visually distinguished from plain cells in the base grid view.

## Extending the Model

IRIELA's norm system is designed to be extensible:
- New **obligations**, **prohibitions**, or **permissions** can be added as additional toggleable entries in the "Model norms" list.
- New **cell covers** or **resource types** can be introduced alongside the existing office/sacred/protected covers and wood/fish resources.
- Additional **indicators** (beyond `daysWithoutFood`) can be tracked per agent or aggregated across the population to study other dimensions of the norm's impact (e.g. compliance rate, resource depletion, sanctions applied).
