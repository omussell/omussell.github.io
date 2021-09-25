+++
title = "Lean"
date = 2021-09-25

[taxonomies]
tags = ["lean"]
+++

A collection of notes about the Toyota way, Lean, Theory of Constraints etc. copied from Wikipedia and other sites

# Toyota Production System

## Goal

Design out overburden (muri) and inconsistency (mura), and to eliminate waste (muda).

### Types of waste

- Overproduction
- Time on hand (waiting)
- Transportation
- Processing itself
- Excess inventory
- Movement
- Making defective products
- Underutilised workers

## Concept

### Just-in-time
Make only what is needed, only when it is needed and only in the amount that is needed

### Jidoka
Automation with a human touch

### Poka Yoke

Any mechanism in a process that helps an equipment operator avoid (yokeru) mistakes (poka) and defects by preventing, correcting, or drawing attention to human errors as they occur

### Continuous Improvement
We form a long term vision, then iteratively work towards it

### Kaizen
We improve our business operations continuously, always driving for innovation and evolution

### Genchi Genbutsu
Go to the source to find the facts to make correct decisions


## The right process will produce the right results

- Create continuous process flow to bring problems to the surface
- Use the 'pull' system to avoid overproduction (Kanban)
- Level out the workload (Heijunka)
- Build a culture of stopping to fix problems, to get quality right from the start
- Standardised tasks are the foundation for continuous improvement and employee empowerment
- Use visual control so no problems are hidden
- Use only reliable, thoroughly tested technology that serves your people and processes

## Continuously solving root problems drives organisational learning

- Go and see for yourself to thoroughly understand the situation (Genchi Genbutsu)
- Make decisions slowly by consensus, thoroughly considering all options. Implement decisions rapidly (Nemawashi)
- Become a learning organisation through relentless reflection (Hansei) and continuous improvement (Kaizen)

## Andon

The worker has the ability to stop production when a defect is found, and immediately call for assistance.

Work is stopped until a solution is found.

Stack light / Traffic light - Visual indicator of a machine state or process event

## 5S

```
Seiri       Sort
Seiton      Set in order
Seso        Shine
Seiketsu    Standardise
Shitsuke    Sustain
```

## Theory of Constraints

Organisations can be measured and controlled by variations on three measures:

- Inventory - The money that the system has invested in purchasing things which it intends to sell
- Operational expense - The money the system spends in order to turn inventory into throughput
- Throughput - The rate at which the system generates money through sales

### Constraints

A constraint is anything that prevents the system from achieving its goal. There is always at least one, but at most only a few, at any given time.

If a constraints throughput capacity is elevated to the point where it is no longer the systems limiting factor, this is said to 'break' the constraint.

### Buffers

Buffers are placed before the governing constraint, thus ensuring that the constraint is never starved.

Buffers are also placed behind the constraint to prevent downstream failure from blocking the constraints output.

Buffers used in this way protect the constraint from variations in the rest of the system and should allow for normal variation of processing time and the occasional upset before and behind the constraint.

With one constraint in the system, all other parts of the system must have sufficient capacity to keep up with the work at the constraint and to catch up if time was lost.

### Plant Types (VATI)

The plant types specify the general flow of materials through a system

#### V

Flow is one to many, such as a plant that takes one raw material and can make many final products.

The primary problem in V plants is 'robbing', where on operation (A) immediately after a diverging point 'steals' materials meant for the other operation (B). Once the material has been processed by A, it cannot come back and be run through B without significant rework.

#### A

Flow is many to one, such as where many sub-assemblies converge for a final assembly.

The problem in A plants is synchronising the converging lines so that each supplies the final assembly point at the right time.

#### T

Flow is many to many, similar to I plant (or has multiple lines), which then splits into many assemblies.

T plants suffer from both synchronisation problems of A plants and the robbing problems of V plants.

#### I

Material flows in a sequence of events in a straight line. The constraint is the slowest operation.
