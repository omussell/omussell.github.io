# Factorio

[Factorio](https://www.youtube.com/watch?v=J8SBp4SyvLc) is a factory and logistics automation game which I enjoy playing. The goal is to harvest resources, manufacture components and their associated logistics challenges with an aim towards creating a rocket which can launch into space.

The [Space Age expansion](https://www.youtube.com/watch?v=OiczN-8QKDA) builds upon this and rather than finishing the game at one rocket launch, you need to launch many to build a space platform (spaceship). That platorm can transport you to a different planet which contains new things to harvest and manufacture. The final planet has only a few resources and you have to transport everything you need to it using platforms. 

The following notes are some guidelines for building a factory that I'm trying to follow to provide an overall architecture and structure to the factory across the different planets.

## Goal

- 100 science per minute
- This is low compared to others peoples bases, however, this is only an initial goal for MVP because getting all the way to promethium science is a lot of work in itself before trying to scale up higher.

- Once 100 is reached, the next is 1000, then 10,000 etc.

## Separate the base into cellular factory with cells/districts/blocks

- Each district should be like a state machine, input and output with processing in between. For example, it could be expecting copper plate and iron plate as input to create electronic circuits which are the output.
- Each district should be modular so can copy paste elsewhere
- Some of the items listed in these districts can only be made on specific planets, which is fine, they can stay as those district types. They'll probably be mass producing their items on there anyway.
- Should use trains between districts for input/output. Belts within districts and bots when there is low throughput.

## Outposts to aggregate raw resources

- Miners and furnaces produce a lot of pollution so they should be kept away from the main base area to avoid attracting lots of biters
- Ore like copper and iron should be mined and transported to a more central area with furnaces to be turned into plates.
- Plates can be transported to the manufacturing districts
- Its better for resiliency because the ore patches are spread in every direction so you will have outposts spread out

## Same planet tech

- Each planets unique buildings should remain on that planet. Not just manufacture is isolated, also running them. Otherwise the planets just churn out legendary buildings and ship them to nauvis. 
- The interplanetary logistics should be emphasized.
- When you look at other peoples bases, they end up with legendary quality foundries feeding EM plants, which is great for speed, but you get silly speed in a tiny area. I want it to look organic.
- That should also mean, any tech unlocked on that planet should be used on that planet.
- With exceptions for fusion and biolabs (anything else?)
- Aquilo being the exception since everything has to be shipped in
- If planets unique buildings can produce something, they should produce it and ship it. For example, foundries produce pipes. They have built in prod bonus, which means they can churn out way more pipes than on anywhere else.

- This ties to the cellular architecture and outposts ideas by having multiple planets produce the same output. For example, vulcanus can mass produce pipes, and nauvis can produce pipes too. If any other planet needs pipes, it should be getting them shipped from both planets for resiliency in case one planets production stops.

## Nuclear planets, fusion ships

- Although you can generate electricity on each planet in unique ways, every planet should also use nuclear power. This means you need to mine and ship uranium from nauvis. It also means every planet always has some form of generation which will always work as a base load.
- Space ships (and probably Aquilo) should be fusion powered. They make more sense given their constrained space requirements.
- In addition to Nuclear, planet power sources should be varied to prevent any single point of failure. 
    - Nauvis - Solar
    - Fulgora - Lightning
    - Vulcanus - Sulfuric acid steam
    - Gleba - Heating towers
    - Aquilo - Fusion
- Could also have battery/accumulator storage in case all other power networks are down

## Quality should be mostly ignored and Rare when it makes sense

- For items where quality makes a big difference, mass produce Rare and bin/recycle all other quality below (and above)
- The quality production should be in a separate district since they'll be siphoning off a lot of the initial items and you dont want it consuming all of them

## If it can take modules, it should have modules

- More likely to be adding modules in mid to late game
- Most efficient is to have productivity inside the machine and speed in beacon
- Should only apply modules if created them with base
- Productivity can only be used on intermediate products

## A standard cargo carrier design for moving items between planets

- You will need to move components between planets continuously and with multiple platforms. Create a standard design, maybe with multiple sizes of cargo capacity.

## Promethium science requirements

Promethium science pack x 10 is:

- 25 promethium chunks
- 1 quantum processor
- 10 biter eggs

They are produced in a cryogenic plant and on a space platform

- Promethium chunks are gathered by flying towards the shattered planet
- That in itself requires a self sustaining space platform
- They dont stack so need more cargo space. Dont store on belts, thats a hack.
- The huge asteroids would need breaking up using railguns
- Railguns need a lot of resources to craft. Quantum processors x 100 amongst other things.

Quantum processors are crafted in electromagnetic plant on aquilo

They require:

- blue circuit
- tungsten carbide
- superconductor
- carbon fiber
- lithium plate
- fluoroketone (cold)

All of that requires interplanetary logistics since they all originate from the other planets

Biter eggs are produced in captive biter spawners

They can be crafted:

- 15 uranium-235
- 10 biter egg
- 1 capture bot rocket
- fluoroketone (cold)

Creating the eggs:

- The spawners themselves spoil quickly into a biter so must be placed somewhere
- Once placed they must be fed a constant supply of bioflux to remain in captured state. Otherwise it degrades back into a normal biter spawner. It can be recaptured again with a capture rocket.
- Bioflux comes from gleba
- Biter eggs spoil quickly, within 30 mins

Promethium carrier platforms

- You would need to figure out which way around to do space platforms. Would it travel out towards shattered planet then come back to nauvis to get eggs? Or would you fill a rocket with eggs, send them to aquilo when the shattered planet run is back, transfer everything to surface and back up again to dedicated platform? Or maybe meet somewhere halfway like gleba?
- I think you'd travel to get promethium chunks, then stop at aquilo to pick up quantum processors, then back to nauvis to get biter eggs, and send down the finished promethium science while you're there. Then head out again.
- Looking at these ingredients, maybe the ship should be doing the rounds across every planet to pick up all the specific things for quantum processors on the way back to aquilo, drop them off while it heads to shattered planet. Its going to need to pick up other stuff anyway like fuel and ammo (because you'd be mass crafting railgun ammo on vulcanus maybe instead of on the platform?)
- You cant transfer between platforms so to avoid having to ferry items to and from a planet and be constrained by the limits on rocket capacity, you would want to have it on one ship.


