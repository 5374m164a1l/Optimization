#wether regular or overtime

using JuMP, Clp, Printf

d = [40 60 70 25]                   # monthly demand for boats

m = Model(with_optimizer(Clp.Optimizer))

@variable(m, 0 <= x[1:4] <= 40)       # boats produced with regular labor
@variable(m, y[1:4] >= 0)             # boats produced with overtime labor
@variable(m, h[1:5] >= 0)             # boats held in inventory
@variable(m, c_neg[1:4] >= 0)            #
@variable(m, c_pos[1:4] >= 0)            #


@constraint(m, h[1] == 10)  #as in previous variations, assume 10 boats on hand initially
@constraint(m, h[2] == h[1] + x[1] + y[1] - d[1])
@constraint(m, h[3] == h[2] + x[2] + y[2] - d[2])
@constraint(m, h[4] == h[3] + x[3] + y[3] - d[3])
@constraint(m, h[5] == h[4] + x[4] + y[4] - d[4])
@constraint(m, h[5] >= 10)
@constraint(m, x[1] + y[1] - 50 >= c_pos[1] - c_neg[1] )
@constraint(m, x[2] + y[2]-(x[1] + y[1]) >= c_pos[2] - c_neg[2] )
@constraint(m, x[3] + y[3]-(x[2] + y[2]) >= c_pos[3] - c_neg[3] )
@constraint(m, x[4] + y[4]-(x[3] + y[3]) >= c_pos[4] - c_neg[4] )

@constraint(m, flow[i in 1:4], h[i] + x[i] + y[i] == d[i] + h[i+1])     # should this include the smoothing?

@objective(m, Min, 400*sum(x) + 450*sum(y) + 20*sum(h) + 400*sum(c_pos) + 500*sum(c_neg))# minimize costs

optimize!(m)

@printf("Boats to build regular labor: %d %d %d %d\n", value(x[1]), value(x[2]), value(x[3]), value(x[4]))
@printf("Boats to build extra labor: %d %d %d %d\n", value(y[1]), value(y[2]), value(y[3]), value(y[4]))
@printf("Inventories: %d %d %d %d %d\n ", value(h[1]), value(h[2]), value(h[3]), value(h[4]), value(h[5]))
@printf("Production increase cost: %d %d %d %d %d\n ", value(c_pos[1]), value(c_pos[2]), value(c_pos[3]), value(c_pos[4]))
@printf("Production decrease cost: %d %d %d %d %d\n ", value(c_neg[1]), value(c_neg[2]), value(c_neg[3]), value(c_neg[4]))

@printf("Objective cost: %f\n", objective_value(m))
