# Constants
R = 8.3145  # Universal gas constant (J/mol·K), helps calculate energy changes for gasses
F = 96485   # Faraday constant (C/mol e-), counts how electric charges move around (like counting electrons)
T = 973.15   # Temperature in K, 700 degrees Celcius = 973.15 Kelvin, the cell's temperature
num_electrons = 4 # Number of electrons per mole of fuel (CH4 oxidation), means every molecule of methane (the fuel) gives off 4 electrons
i_values = [1.0, 2.5]  # Current densities in A/cm², lists 2 eletric current stengths (how hard we're pushing electricity through the cell)
area_resistance = 0.1  # Area-specific resistance in Ω·cm², measures how tough it is for electricity to flow in the cell

# Gas concentrations (mol/m³), figuring out gas amounts
# we are figuring out how many oxygen molecules (on the air side) and methane molecules (on the fuel side) are present inside the cell, 
# these values depend on the gas concentrations given (percentages turned into numbers), the gas constant (R) and the temperature (T)
C_O2 = 0.18 * 101325 / (R * T)  # Cathode-side oxygen concentration
C_CH4 = 0.60 * 101325 / (R * T) # Anode-side methane concentration
# anode = electrons flow out (oxidation)
# cathode = electrons flow in (reduction)

# Diffusivity and thickness
#tiny gas molecules moving through sponge-like layers in the cell
D_c = 3.66e-7  # Effective diffusivity at cathode (m²/s), how quickly the gases move through the layers on the air side (cathode)
delta_c = 10e-6 # Diffusion layer thickness at cathode/electrolyte interface (m), how thick the sponge-like layers are for cathode side
D_a = 9.66e-7  # Effective diffusivity at anode (m²/s), how quickly gas moves through the layers on the fuel side (anode)
delta_a = 200e-6 # Diffusion layer thickness at anode/electrolyte interface (m), how thick the sponge-like layers are for the anode side

# Exchange current densities (A/m²)
# we calculate "baseline electric currents" at the cathode and anode
# i0_c and i0_a, these depend on gas concentrations (C_O2 and C_CH4) and temperature (T), the exp() function handles temperature effects
i0_c = 3.8e6 * exp(-8170 / T) * C_O2 #baseline electric current at cathode, this is influenced by how much oxygen is available and how efficiently it reacts at the cathode
i0_a = 1.3e7 * exp(-8427 / T) * C_CH4 #baseline electic current at anode, this depends on the methane concentration and how well it participates in reactions on the fuel side 
#the "baseline currents" reflect the ability of the cell to initiate chemical reactions at each electrode, even without much external current being applied
#think of them as the starting strength of each side's reaction capabilites under the given conditions



# Functions for overpotentials 

# Activation Overpotential - is calculated for both cathode and anode using Tafel equation
# This calculates energy losses when chemical reactions happen in the cell
# i is the current we're using
# i0 is the baseline current 
# alpha is a number that tells how good the chemical reactions are (we set it to 0.5)

function activation_overpotential(i, i0, alpha)
    return (R * T / (alpha * F)) * log(i / i0)
end

# Diffusion Overpotential - uses Fick's Law to account for concentration gradients in porous layers
# This checks energy losses from gas molecules struggling to move through the sponge-like layers
# C_star is the gas concentration
# D and delta describe the layers where gas moves
function diffusion_overpotential(i, C_star, D, delta)
    return (R * T / (num_electrons * F)) * log(1 + (i / (F * D * C_star / delta)))
end

# Calculate overpotentials and operating voltage
# This part runs the calculation for each current density (i=1.0, 2.5)
# ------
# It calculates activiation losses for both air and fuel sides
# Activation Losses, in a fuel cell, the chemical reactions (like oxygen combining with electrons) need a bit of "push" to start working,
#this push is called activation energy, activation losses are like the energy the cell "loses" to get those reactions going
# if the reactions are slow or difficult, the activation losses are bigger
# -------
# The diffusion losses for air and fuel sides
# Diffusion Losses = the fuel (like methane or oxygen) needs to travel through sponge-like layers to reach the spots where chemical reactions happen,
# Diffusion losses occur because it's not easy for the gas molecules to move through these layers - they get "stuck" or slowed down
# The thicker the layer or the harder it is for the gas to diffuse (spread out), the bigger the loss
# ------
# adds ohmic losses (resistance effects) - based on the area-specific resistance and current desnisty
# ohmic losses - in a fuel cell, as electicity moves through the cell's materials (like wires or layers), it faces resistance, 
# like trying to push through a narrow or challenging path
# This "fighting against resistance" wastes some of the cell's energy, and that wasted energy is called ohmic losses
# the more resistance there is, the more energy is lost
#-----------
# Operating voltage is estimated by subtracting all overpotentials and losses from the theoretical Nernst Voltage (1.229 V)
# subtracts all the losses from the ideal voltage (1.229 V) to find the actual voltage
# it prints the result (operating voltages for the 2 currents)
for i in i_values
    eta_activation_c = activation_overpotential(i, i0_c, 0.5)
    eta_activation_a = activation_overpotential(i, i0_a, 0.5)
    eta_diffusion_c = diffusion_overpotential(i, C_O2, D_c, delta_c)
    eta_diffusion_a = diffusion_overpotential(i, C_CH4, D_a, delta_a)
    eta_ohmic = area_resistance * i

    operating_voltage = 1.229 - (eta_activation_c + eta_activation_a +
                                 eta_diffusion_c + eta_diffusion_a + eta_ohmic)
    println("Operating Voltage at i = $i A/cm²: $operating_voltage V")
end


# Operating Voltages - Code Outputs
# Operating Voltage at i = 1.0 A/cm²: 4.030645268779439 V 
# Operating Voltage at i = 2.5 A/cm²: 3.5733182639768324 V

#= ----------------------------------------------------------------
Comment on the maximum average current density that can be produced by the cell under these conditions.

From the code outputs the operating voltage decreased from approximately 4.03 V to 3.57 V
as the the average current density was increased from 1.0 A/cm² to 2.5 A/cm². 
Maximum average current density is used to determine the maximum current flow of a system before it's perfomance significantly degrades. 
As more current goes through the fuel cell, energy gets lost, when overpotentials such as diffusion losses and activation losses
get too large, the fuel cell becomes inefficient and the voltage drops as it reaches the limiting current density. 
--------------------------------------------------------------------=# 