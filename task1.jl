using JuMP, GLPK

M = 90
T = 10
cost = [M 1 10 M M M
        M M M 1 2 M
        M 1 M M 12 M
        M M M M 10 1
        M M M M M 2
        M M M M M M]
time = [M 10 3 M M M
        M M M 1 3 M
        M 2 M M 3 M
        M M M M 1 7
        M M M M M 2
        M M M M M M]



# ------------------
# YOUR MODEL IN HERE
# ------------------
u = 5
for u=0:0.1:10
    model = Model(GLPK.Optimizer)

    @variable(model, x[1:6,1:6]>=0)
    @objective(model,Min,sum(sum(cost[i,j]*x[i,j] for i=1:6) for j=1:6)-u*(T-sum(sum(time[i,j]*x[i,j] for i=1:6) for j=1:6)))

    #@constraint(model,sum(sum(time[i,j]*x[i,j] for i=1:6) for j=1:6) <= T)

    @constraint(model,sum(x[1,j] for j=1:6) == 1)
    @constraint(model,sum(x[i,6] for i=1:6) == 1)

    @constraint(model,[k=2:5],sum(x[i,k] for i=1:6)== sum(x[k,j] for j=1:6))

    JuMP.optimize!(model)
    if termination_status(model) == MOI.OPTIMAL
        println()
        println("u = ",u)
        println("Objective is: ", JuMP.objective_value(model))
        println("Solution is: ")
        for i=1:6
            for j=1:6
                if(JuMP.value(x[i,j])>0)
                    print(i , j )
                    println(JuMP.value(x[i,j]))
                end
            end
        end
        println("path cost: ", sum(sum(cost[i,j]*JuMP.value(x[i,j]) for i=1:6) for j=1:6))
        println("Travel time: ", sum(sum(time[i,j]*JuMP.value(x[i,j]) for i=1:6) for j=1:6))

    else
        println("Optimise was not successful. Return code", termination_status(model))
    end
end