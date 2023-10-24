using JuMP, Gurobi


# Number of tasks
n = 6

# Number of teams
k = 3

# Cost vector
s = [100 200 400 500 900 700]

model = Model(Gurobi.Optimizer)

@variable(model, x[1:n,1:k], Bin)
@variable(model, c[1:k] >= 0)
@variable(model, d[1:k,1:k])
@variable(model, u[1:k,1:k] >= 0)

@objective(model, Min, sum(u[i,j] for i=1:k, j=1:k))

@constraint(model, [i=1:n], sum(x[i,p] for p=1:k) == 1)
@constraint(model, [p=1:k], sum(x[i,p] for i=1:n) >= 1)

@constraint(model, [p=1:k], c[p] == sum(x[i,p]*s[i] for i=1:n))

@constraint(model, [p=1:k,pp=1:k], d[p,pp] == c[p] - c[pp])
@constraint(model, [p=1:k,pp=1:k], u[p,pp] >= d[p,pp])
@constraint(model, [p=1:k,pp=1:k], u[p,pp] >= -d[p,pp])

JuMP.optimize!(model)

if termination_status(model) == MOI.OPTIMAL
    println("Objective is: ", JuMP.objective_value(model))
    println("Solution is: ")
    for p=1:k
        println("Team ", p, " - Time: ", JuMP.value(c[p]))
    end
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
