#wether regular or overtime

using JuMP, Clp, Printf

d = [40 60 70 25]                   # monthly demand for boats

m = Model(with_optimizer(Clp.Optimizer))

@variable(m, 0 <= x[1:4] <= 40)       # boats produced with regular labor
@variable(m, y[1:4] >= 0)             # boats produced with overtime labor
@variable(m, h_pos[1:5] >= 0)             # boats excess
@variable(m, h_neg[1:5] >= 0)             # boats owed
@variable(m, c_neg[1:5] >= 0)            # production decrease
@variable(m, c_pos[1:5] >= 0)            # production increase

#how to condense constraints into 1 or 2 lines? different situation from topbrass
@constraint(m, h_pos[1] - h_neg[1] == 10 + x[1] + y[1] - d[1])  #as in previous variations, assume 10 boats on hand initially
@constraint(m, h_pos[2] - h_neg[2] == h_pos[1] - h_neg[1] + x[2] + y[2] - d[2])
@constraint(m, h_pos[3] - h_neg[3] == h_pos[2] - h_neg[2] + x[3] + y[3] - d[3])
@constraint(m, h_pos[4] - h_neg[4] == h_pos[3] - h_neg[3] + x[4] + y[4] - d[4])
@constraint(m, h_neg[4] <= 0)
@constraint(m, h_pos[4] >= 10)
@constraint(m, x[1] + y[1] - 50 >= c_pos[1] - c_neg[1] )
@constraint(m, x[2] + y[2]-(x[1] + y[1]) >= c_pos[2] - c_neg[2] )
@constraint(m, x[3] + y[3]-(x[2] + y[2]) >= c_pos[3] - c_neg[3] )
@constraint(m, x[4] + y[4]-(x[3] + y[3]) >= c_pos[4] - c_neg[4] )
#supposed to use anonymous construction because 'flow' not allowed twice
@constraint(m, flow[i in 1:4], h_pos[i] - h_neg[i] + x[i] + y[i] == d[i] + h_pos[i+1]-h_neg[i+1])     # should this include the smoothing and backlog?
@constraint(m, flow[i in 1:4], x[i+1] + y[i+1]-(x[i] + y[i]) >= c_pos[i+1] - c_neg[i+1])# I think this should be here, 80% confident

@objective(m, Min, 400*sum(x) + 450*sum(y) + 20*sum(h_pos) + 100*sum(h_neg) + 400*sum(c_pos) + 500*sum(c_neg))# minimize costs

optimize!(m)

@printf("Boats to build regular labor: %d %d %d %d\n", value(x[1]), value(x[2]), value(x[3]), value(x[4]))
@printf("Boats to build extra labor: %d %d %d %d\n", value(y[1]), value(y[2]), value(y[3]), value(y[4]))

@printf("Production increase cost: %d %d %d %d %d\n ", value(c_pos[1]), value(c_pos[2]), value(c_pos[3]), value(c_pos[4]))
@printf("Production decrease cost: %d %d %d %d %d\n ", value(c_neg[1]), value(c_neg[2]), value(c_neg[3]), value(c_neg[4]))

@printf("Surplus: %d %d %d %d %d\n ", value(h_pos[1]), value(h_pos[2]), value(h_pos[3]), value(h_pos[4]))
@printf("Backlog: %d %d %d %d %d\n ", value(h_neg[1]), value(h_neg[2]), value(h_neg[3]), value(h_neg[4]))


@printf("Objective cost: %f\n", objective_value(m))
