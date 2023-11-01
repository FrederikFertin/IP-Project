using JuMP, GLPK

# Number of assignments in the matrix
W = 21

# Number of assignments/teams in the solution
k = 3

# Number of tasks in the problem
t = 6

# Matrix is column by column,  so first index is column and second index is row
D = [1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
    0 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0;
    0 0 1 1 1 1 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0; 
    0 0 0 1 1 1 0 0 1 1 1 0 1 1 1 1 1 1 0 0 0; 
    0 0 0 0 1 1 0 0 0 1 1 0 0 1 1 0 1 1 1 1 0;
    0 0 0 0 0 1 0 0 0 0 1 0 0 0 1 0 0 1 0 1 1]

# Cost vector
c = [100 300 700 1200 2100 2800 200 600 1100 2000 2700 400 900 1800 2500 500 1400 2100 900 1600 700]

# Initialise model
model = Model(GLPK.Optimizer)

# Decision variables
@variable(model, x[1:W], Bin)
@variable(model, Z)

# Each task should be done exactly once
@constraint(model, [j=1:t], sum(x[i]*D[j,i] for i=1:W) == 1)

# The number of assignments chosen should be equal to the number of teams
@constraint(model, sum(x) == k)

# Z is larger than all team costs
@constraint(model, [i=1:W], Z >= x[i]*c[i])

# Objective function minimizing the maximum assignment cost
@objective(model, Min, Z)

JuMP.optimize!(model)

if termination_status(model) == MOI.OPTIMAL
    println("Objective is: ", JuMP.objective_value(model))
    println("Solution is: ")
    for i=1:W
        if (JuMP.value(x[i]) > 0.5)
            print(i, ": ")
            for j=1:t
                if (D[j,i]==1)
                    print(j," ")
                end
            end
            println()
        end
    end
else
    println("Optimise was not successful. Return code", termination_status(model))
end
