using JuMP, GLPK


# Number of assignments in the matrix
W= 21

# Number of assignments in the Solution
k = 3

# Number of tasks in the problem
t = 6

# Matrix is column by column,  so first index is column and second index is row
D =[1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
    0 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0;
    0 0 1 1 1 1 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0; 
    0 0 0 1 1 1 0 0 1 1 1 0 1 1 1 1 1 1 0 0 0; 
    0 0 0 0 1 1 0 0 0 1 1 0 0 1 1 0 1 1 1 1 0;
    0 0 0 0 0 1 0 0 0 0 1 0 0 0 1 0 0 1 0 1 1]

s = [100 200 400 500 900 700]

# Cost vector
c = [100 300 700 1200 2100 2800 200 600 1100 2000 2700 400 900 1800 2500 500 1400 2100 900 1600 700]

model = Model(GLPK.Optimizer)

@variable(model, x[1:W], Bin)
@variable(model, Z)

@objective(model, Min, T)

@constraint(model, [j=1:t], sum(x[i]*D[j,i] for i=1:W) == 1)

@constraint(model, sum(x) == k)

@constraint(model, [i=1:W], Z >= x[i]*c[i])

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
