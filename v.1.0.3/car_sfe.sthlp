{smcl}
{* *! version 1.0.0 12oct2017}{...}
{cmd:help car_sfe}
{hline}

{title:Title}

    {hi:car_sfe} {c -} Fully saturated linear regression with covariate-adaptive randomization standard error adjustment

{title:Syntax}
{p 8 17 2}
{cmd:car_sfe} {it:dep_var} {it:treat_var} [{opt if}]{cmd:,}
 {opt strata:(strat_var)} 


{title:Description}

{pstd}
{cmd:car_sfe} is a estimation command that estimates a "strata fixed effects" regression (that is, a regression of 
{it:dep_var} on indicators for {it:treat_var} and {it:stratvar}) and calculates
the estimated coefficient of {it:treat_var} as well as its standard error adjusted to take into account 
potential bias from covariate-adaptive randomization, as per Bugni, Canay, and Shaikh (2017).
{p_end}


{title:Saved Results}

{phang}
{cmd:car_sfe} saves the following in {cmd:e()}:{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}

{synopt:{cmd:e(df_r)}}degrees of freedom{p_end}
{synopt:{cmd:e(N)}}sample size{p_end}
{p2colreset}{...}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:car_sfe}{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{p2colreset}{...}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{p2colreset}{...}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:Author}

{phang}
Joe Long{p_end}
{phang}
jlong@u.northwestern.edu
{p_end}

{title:References}

{phang}
Bugni, Federico A., Ivan A. Canay, and Azeem M. Shaikh. (2017) "Inference under Covariate-Adaptive Randomization with Multiple Treatments." 
