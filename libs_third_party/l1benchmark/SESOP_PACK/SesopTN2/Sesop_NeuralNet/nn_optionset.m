function options= sesoptn_optionset()
% Setup options structure for sesoptn optimization function
%
%Call:
%  options=optionset_sesop()

% Michael Zibulevsky, 11.07.2008; 27.07.2008; 29.07.2008


options.max_sesop_iter=50;    % Max  SESOP iterations
options.max_newton_iter=5;     % Max Newton iterations in subspace optimization
options.max_iter_CGinTN = 10;  % Conj.Grad steps in Truncated Newton (if  set to 0, TN  not used)
options.FlagNonlinCG  = 0;     % 1 - Polak-Ribiere Nonlinear Conjugate Gradient method; 0 - any other method


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Directions to be included in  SESOP  subspace 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options.nLastSteps=2;   % SESOP subspace will include: nLastSteps + [precond] gradient +
                        %                 +[3 TN directions] + [2 Nemirovski directions])

options.precond=0;         % 1 - use user-defined  preconditioner, 0 - don't
options.mult_precond =[];  % User function d_new=options.mult_precond (-g, x, par);

options.PureTN=0;   %  1 - Pure Truncated Newton; 0 - Truncated Newton with  SESOP (recommended); 

options.FlagNemirovski_dir=1;  % 1 - Add two directions of Nemirovski: x-x0 and  sum w_k*g_k
                               % This guarantees worst-case optimal complexity of the method, but increases a bit 
							   % average  complexity 

																
																
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        Result Reporting options 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%																
																
options.ShowSesopPlots=1;           % 1 - plot iteration progress, 0 - don't
options.period_show_progress=5;     % Periodicity of showing sesop and user plots
options.period_show_progressCG=1e5;

options.report_func=[];   % User function reference to display/collect iteration progress;
                          % Call:   options.report_func(x,report,par);
						  % Input:  report.gradnorms    - array of gradient norms with iteration 
				          %         report.func_values  - array of objective function values with iteration;
						  %         report.Niter        - current sesop_iter;   ;

options.sesop_figure_name=sprintf('SESOPtn progress,   %d CG steps per TN iteration',options.max_iter_CGinTN);


options.TESTGRAD=0;  % 1 - Test gradient numerically, plot testing results (without run optimization); 0 - don't test


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       SESOP stopping criteria: if any of them is satisfied, SESOP terminates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options.dxTol=1e-8;    % norm(change_in_x)
options.dfTol=1e-12;   % |change_in_objective_func|
options.gTol=1e-8;     % norm(gradient)


% Michael Zibulevsky,  25.11.2007; 05.08.2008
% Copyright (c) 2008.  All rights reserved. Free for academic use. No warranty 
