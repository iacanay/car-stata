*Example file*

*Generate data
clear
set obs 1000
gen A = round(runiform()*2)							// 2 treatments
gen S = round(_n/_N*9) + 1							// 10 strata
gen Y = 0.1 * A + rnormal()
gen covar1 = runiform()
gen covar2 = runiform()

*Mark samples
gen sample1 = A < 2									// 1-treatment sample
gen sample2 = 1										// 2-treatment sample

*Run regressions
*Manual check
reg Y i.S i.A#i.S if sample1
mat b = e(b)
mat b_sat = b[1, 21..30]
tab S if sample1, matcell(ns)
cou if sample1
mat theta = b_sat*ns/r(N)
mat li theta

*Command
car_sat Y A if sample1, strata(S)					// 1-treatment, SAT
car_sat Y A if sample1, strata(S) table				// 1-treatment, SAT

car_sat Y A if sample2, strata(S)					// 2-treatment, SAT
test A_1 == A_2 									// F-test that treatment 1 = 2

car_sat Y A if sample2, strata(S) covars(covar*)	// 2-treatment, SAT
gen S2 = mod(_n, 4)
forv n = 0/3 {
	gen S2_`n' = S2 == `n'
}

car_sat Y A if sample2, strata(S) covars(S2_*)		// collinearity check
