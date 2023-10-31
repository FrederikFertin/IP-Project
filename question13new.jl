using JuMP, Gurobi


# Number of tasks
n = 6

# Number of teams
k = 3

# Cost vector
s = [100 200 400 500 900 700]

model = Model(Gurobi.Optimizer)

@variable(model, x[1:n,1:k], Bin)
@variable(model, Z)

@objective(model, Min, Z)

@constraint(model, [i=1:n], sum(x[i,p] for p=1:k) == 1)
@constraint(model, [p=1:k], sum(x[i,p] for i=1:n) >= 1)

@constraint(model, [p=1:k], Z >= sum(x[i,p]*s[i] for i=1:n))

JuMP.optimize!(model)

if termination_status(model) == MOI.OPTIMAL
    println("Objective is: ", JuMP.objective_value(model))
    println("Solution is: ")
    println("Time: ", JuMP.value(Z))
    println("Allocation is: ")
    for p=1:k
        println("Team", p, ":")
        println("Tasks: ")
        for i=1:n
            if JuMP.value(x[i,p]) >= 0.5
                print(i, " ")
            end
        end
        println()
    end
else
    println("Optimise was not successful. Return code", termination_status(model))
end
