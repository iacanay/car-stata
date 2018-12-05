*! version 1.0.0 Joe Long 05oct2018
pr car_sfe, eclass
	version 14.0
	syntax varlist [if] [in], Strata(varlist) [table]
	
	************
	*ROBUSTNESS*
	************
	marksample touse
	gettoken Y rest: varlist
	gettoken A leftover: rest
	
	*Check there aren't extra variables
	if "`leftover'" != "" {
		di as err "Extraneous independent variables"
		exit 198
	}
	*Check strata is one variable 
	unab slist: `strata'
	if `:word count `slist'' != 1 {
		di as err "Strata must be as one variable"
		exit 198
	}
	
	*******************************************
	*GENERATE VARIABLES/LOCALS FOR CALCULATION*
	*******************************************
	qui levelsof `strata' if `touse', l(groups)
	qui su `A' if `touse', d
	loc Amax = r(max)
	loc s = 0
	foreach strat of loc groups {
		*First check if the strata has any empty cells
		loc check_strat = 0 
		forv a = 0/`Amax' {
			qui cou if `strata' == `strat' & `A' == `a' & `touse'
			if `r(N)' == 0 {
				loc ++check_strat
			}
		}
		*If strata has no empty cells, then save all indicator variables in strata to use
		if `check_strat' == 0 {
			loc ++s 
			forv a = 1/`Amax' {
				tempvar I_`a'_`s'
				gen `I_`a'_`s'' = `strata' == `strat' & `A' == `a' & `touse'
			}
			tempvar I_`s'
			gen `I_`s'' = `strata' == `strat' & `touse'
			loc Scal `Scal' `I_`s''
		}
		*Otherwise, mark the strata as defective, ignore strata
		else {
			replace `touse' = 0 if `strata' == `strat' & `touse'
		}
	}
	forv a = 1/`Amax' {
		tempvar A_`a'
		gen `A_`a'' = `A' == `a' & `touse' 
		loc treats `treats' `A_`a''
		loc s = 0 
		foreach strat of loc groups {
			loc ++s
			loc interaction `interaction' `I_`a'_`s''
		}
		loc column `column' treatment_`a'
	}
	
	*********
	*REGRESS*
	*********
	tempname b V N df b2 V2
	noi mata: myregress("`Y'", "`Scal'", "`interaction'", "`touse'", "`b'", "`V'", "`N'", "`df'", "`treats'")

	********
	*OUTPUT*
	********
	mat coln `b' = `column'
	mat rown `b' = "`A'"
	mat coln `V' = `column'
	mat rown `V' = `column'
	
	ereturn post `b' `V', esample(`touse') dof(`=`df'')
	eret display
	eret scalar N = `N'
	eret local cmd "sat_mata"
	
end

*****************
*MATA REGRESSION*
*****************
mata:
	mata clear
	void myregress(string scalar depvar_s, string scalar strata_s, string scalar interact_s, ///
		string scalar touse_s, string scalar b_s, string scalar v_s, ///
		string scalar n_s, string scalar df_s, string scalar treatment)
	{
		real vector y, Xpy, beta, beta_sfe, e2, N_s, T, I_S
		real matrix X, X_sfe, XpXi, XpeepX, B, V_H, R, vc, S_cal, V_hc
		real scalar k, n, S, A
		
		y 		= st_data(., depvar_s, touse_s)
		X 		= st_data(., (tokens(strata_s), tokens(interact_s)), touse_s)
		X_sfe 	= st_data(., (tokens(treatment), tokens(strata_s)), touse_s)
		S_cal 	= st_data(., strata_s, touse_s)
		n 		= rows(y)
		S 		= cols(S_cal)
		N_s		= colsum(S_cal)/n
		I_S 	= J(1, S, 1)
		k		= cols(X)
		Xpy 	= quadcross(X, y)
		XpXi 	= cholinv(quadcross(X, X))
		beta 	= XpXi * Xpy
		beta_sfe = cholinv(quadcross(X_sfe, X_sfe))*quadcross(X_sfe, y)
		e2 		= (y - X*beta):^2
		XpeepX 	= quadcross(X, e2, X)
		vc 		= n * quadcross(quadcross(XpXi', XpeepX)', XpXi) * n/(n-k)

		B 		= colshape(beta, S)[|2,1\.,.|]
		A 		= rows(B)
		T 		= B * N_s'
		V_H 	= quadcross((B - T*I_S)', N_s, (B - T*I_S)')
		R 		= J(A, S, 0)
		for (i=1; i<=S; i++) {
			R = R, diag(J(A, 1, N_s[i]))
		}
		V_hc 	= quadcross(quadcross(R', vc)', R')

		st_matrix(b_s, beta_sfe[1..A,1]')
		st_matrix(v_s, (V_H + V_hc)/n)
		st_numscalar(n_s, n)
		st_numscalar(df_s, n-k) 
	}	
end
