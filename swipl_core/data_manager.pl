:- module(data_manager,[
		criterion/2,
		alternative/1,
		profile_rule/2,
		cpref_rule/2,
		fact/3,
		cpref_rules_order/1,
		
		add_alternative/2,
		
		remove_alternative/1,
		remove_alternatives/0,
		
		add_criterion/2,
		remove_criterion/1,
		remove_criteria/0,
		
		add_feature/2,
		remove_feature/1,
		remove_features/0,
		
		add_cpref_rule/2,
		remove_cpref_rule/1,
		remove_cpref_rules/0,
		
		define_cpref_rules_order/1,
		
		generate_random_evidence/1
	]).


	:- dynamic criterion/2.
	:- dynamic alternative/1.
	:- dynamic cpref_rule/2.
	:- dynamic fact/3.
	:- dynamic cpref_rules_order/1.
	
	
	:-use_module(cpref_rules_interpreter, [correct_cpref_rule/1, op(1101, xfx, ==>)]).
	
	
	/***********************************************************************************
		add_alternative(+Id,+Evidence).
		
		Add an alternative to the decision-base.
		Id is the alternative's ID and +Evidence are the values for ID according to
		each preference criterion.
			
	************************************************************************************/
	add_alternative(Id,Evidence):-
		not(alternative(Id)),!,
		assert(alternative(Id)),
		forall(member([Criterion,Value], Evidence),(
			criterion(Criterion),
			assert(fact(Criterion, Id, Value))
		)).
	
	% If it fails, execute contingency plan and fail.	
	add_alternative(Id,_Evidence):-
		alternative(Id),
		retract(alternative(Id)),
		false.
	
	
	/***********************************************************************************
		remove_alternative(+Id).
		
		Removes the alternative Id from the decision-base.
			
	************************************************************************************/
	remove_alternative(Id):-
		retract(alternative(Id)),
		
		%Remove related evidence.
		forall(feature(Feature),(
			retract(fact(Feature,Id,_))
		)),
		
		%Remove related assessments.
		remove_assessments(Id).
		
		
	/***********************************************************************************
		remove_alternatives.
		
		Removes all alternatives from the decision-base.
			
	************************************************************************************/
	remove_alternatives:-
		retractall(alternative(_)),
		
		%Remove related evidence.
		retractall(fact(_,_,_)),
		
		%Remove assessments.
		remove_assessments.
		
	
	/***********************************************************************************
		add_criterion(+Criterion,+Values).
		
		Add a new criterion Criterion to the decision-base.
		Values is the valid range of values Criterion can be assessed with.
		
		Values must be a set [v_1, ..., v_n] such that v_i is interpreted to be better
		than v_(i-1) with 1 <= i <= n.
		Alternativelly, Values may be instantiated with "interval(Initial, Final)" to
		represent the integer close interval [Initial,Final].
			
	************************************************************************************/
	add_criterion(Criterion, Values):-
		not(criterion(Criterion,_)),
		check_criterion_values(Values),
		
		assert(criterion(Criterion,Values)).
	
	check_criterion_values(interval(Initial,Final)):-!, integer(Initial), integer(Final).
	check_criterion_values(Values):- is_set(Values).
	
	
	/***********************************************************************************
		remove_criterion(+Criterion).
		
		Removes the criterion Criterion from the decision-base.
			
	************************************************************************************/
	remove_criterion(Criterion):-
		retract(criterion(Criterion,_)).
	
	
	/***********************************************************************************
		remove_criteria.
		
		Removes all criteria from the decision-base.
			
	************************************************************************************/
	remove_criteria:-
		retractall(criterion(_,_)).
	
	
	
	/***********************************************************************************
		add_cpref_rule(+Id, +Rule).
		
		Adds a new Cpref-Rule Rule associated with Id to the decision-base.
		Before adding the new rule it checks if the rule syntax is correct.
			
	************************************************************************************/
	add_cpref_rule(Id, Rule):-
		correct_cpref_rule(Rule),
		assert(cpref_rule(Id, Rule)).
	
	/***********************************************************************************
		remove_cpref_rule(+Id).
		
		Removes the Cpref-Rule Id from the decision-base.
			
	************************************************************************************/
	remove_cpref_rule(Id):-
		retract(cpref_rule(Id,_)).
	
	
	/***********************************************************************************
		remove_cpref_rules.
		
		Removes all Cpref-Rules from the decision-base.
			
	************************************************************************************/
	remove_cpref_rules:-
		retractall(cpref_rule(_,_)),
		retractall(cpref_rules_order(_)).
	
	
	/***********************************************************************************
		define_cpref_rules_order(+Order).
		
		Defines the priority order between Cpref-rules.
		Order must be an orderer set of rules [r_1, ..., [r_i, ..., r_(i+k)], ..., r_n].
		In this example r_n has the highest priority, r_1 has the lowest proirity.
		Note that is possible to explicit partial orders.
		For instance, r_i ... r_(i+k) have the same priority.
			
	************************************************************************************/
	define_cpref_rules_order(Order):-
		is_set(Order),
		forall(cpref_rule(Id,_), check_cpref_rule_existence(Id,Order)),
		retractall(cpref_rules_order(_)),
		assert(cpref_rules_order(Order)).
	
	%Checks if a rule in a rule_order was previously defined.
	check_cpref_rule_existence(Rule,[Rule|_]):-!.
	
	check_cpref_rule_existence(Rule,[Element|Order]):-
		not(is_list(Element)),!,
		check_cpref_rule_existence(Rule,Order),!.
		
	check_cpref_rule_existence(Rule,[Element|_]):-
		is_set(Element),
		member(Rule,Element),!.
		
	check_cpref_rule_existence(Rule,[Element|Order]):-
		is_set(Element),
		check_cpref_rule_existence(Rule,Order),!.
		
	
	/***********************************************************************************
		generate_random_evidence(+Alternatives_Amount).
		
		Generates a random set of evidence for the amount of alternatives specified with
		Alternatives_Amount.
			
	************************************************************************************/
	generate_random_evidence(Alternatives_Amount):-
		integer(Alternatives_Amount),!,
		remove_alternatives,
		forall(between(1,Alternatives_Amount,Index), (atom_concat('a',Index,Id), assert(alternative(Id)))),
		forall(feature(Feature),generate_random_evidence(Feature)).
		
	
	generate_random_evidence(Criterion):-
		criterion(Criterion,Values),
		forall(alternative(Id),(
			random_value(V,Values),
			assert(fact(Criterion,Id,V))
		)).
	
	
	random_value(V,List):-
		is_list(List),!,
		random_member(V,List).				

	random_value(V,interval(Vi,Vf)):-
		Vi =< Vf,!,
		random_between(Vi,Vf,V).
		
	random_value(V,interval(Vi,Vf)):-
		Vf < Vi,
		random_between(Vf,Vi,V).