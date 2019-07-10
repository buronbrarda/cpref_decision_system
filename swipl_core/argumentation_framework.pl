:- module(argumentation_framework,[
		generate_warranted_conclusions/0,
		generate_dtree_nodes/0,
		
		set_comparison_criterion/1,
		set_rules_order/1,
		reset_rules_order/0,
		
		rules/3,
		premises/3,
		
		dialectical_tree/2,
		
		warranted/1,
		justification/4
	]).
	
	:-use_module(data_manager, [cpref_rules_order/1]).
	:-use_module(utils).
	:-use_module(arg_generator, [argument/4, generate_arguments/0]).
		
	:-dynamic exhaustive_arg_line/2.
	:-dynamic m_dialectical_tree/3.
	
	:-dynamic dtree_node/5.
	
	%===================================================================================
	
	
	
	/***********************************************************************************
		premises(?Premises, ?Id, ?Argument).
		
		True when Premises are the premises of the argument Argument identified with Id.
	************************************************************************************/
	premises(Premises, Id, Arg):-
		argument_id(Id, Arg),
		Arg = argument(Id,_Rules,Premises,_Claim).
	
	
	/***********************************************************************************
		premises(?Rules, ?Id, ?Argument).
		
		True when Rules are the rules of the argument Argument identified with Id.
	************************************************************************************/
	rules(Rules, Id, Arg):-
		argument_id(Id, Arg),
		Arg = argument(Id,Rules,_Premises,_Claim).
		
	
	/***********************************************************************************
		premises(?Claim, ?Id, ?Argument).
		
		True when Claim is the claim of the argument Argument identified with Id.
	************************************************************************************/
	claim(Claim, Id, Arg):-
		argument_id(Id, Arg),
		Arg = argument(Id,_Rules,_Premises,Claim).
	
	
	/***********************************************************************************
		defeats(?Id, ?Arg).
		
		True iff Id is the id of an argument Arg.
	************************************************************************************/
	argument_id(Id,Arg):-
		Arg =.. [argument,Id,_,_,_],
		call(Arg).
	
	
	
	
	/***********************************************************************************
		complement(+ClaimA, +ClaimB).
		
		Define whether a literal is the complement of another literal.
	************************************************************************************/
	complement(pref(X,Y),pref(Y,X)).
	
	
	/***********************************************************************************
		in_conflict(+ArgA, +ArgB).
		
		Define whether two arguments ArgA and Argb are in conflict.
	************************************************************************************/
	in_conflict(argument(_,_,_,ClaimA), argument(_,_,_,ClaimB)):-
		complement(ClaimA,ClaimB).

	
	/***********************************************************************************
		stronger(+ArgA, +ArgB).
		
		Defines whether ArgA is stronger than Argb.
	************************************************************************************/
	stronger(ArgA, ArgB):-
		rules(RulesA,_,ArgA),
		rules(RulesB,_,ArgB),
		r_stronger(RulesA,RulesB).
	
	
	r_stronger(RuleA,RuleB):-
		cpref_rules_order(Order),
		r_index(N,RuleA,Order),
		r_index(M,RuleB,Order),
		N < M.
		
	r_index(0,Rule,[Rule|_]):-!.
	
	r_index(0,Rule,[Element|_]):-
		member(Rule,Element),!.
	
	r_index(Index,Rule,[_|Order]):-
		r_index(Aux,Rule,Order),!,
		Index is Aux + 1.
	
	/***********************************************************************************
		defeats(?Defeater, ?Defeated).
		
		Defines whether an argument defeats another one. 
	************************************************************************************/
	defeats(Defeater_Id,Defeated_Id):-
		argument_id(Defeater_Id,Defeater),
		argument_id(Defeated_Id,Defeated),
		
		in_conflict(Defeater,Defeated),
		stronger(Defeater,Defeated).
		
	
	/***********************************************************************************
		blocks(?Blocker, ?Blocked).
		
		Defines whether an argument blocks another one. 
	************************************************************************************/
	blocks(Blocker_Id, Blocked_Id):-
		argument_id(Blocker_Id,Blocker),
		argument_id(Blocked_Id,Blocked),
		
		in_conflict(Blocker,Blocked),
		not(stronger(Blocker, Blocked)), 
		not(stronger(Blocked,Blocker)).	
	
	
	
	
	/*===================================================================================
		
		
		THE FOLLOWING PREDEICATES DEFINES THE ARGUMENTATION FRAMEWORK SEMANTIC
		
		
	===================================================================================*/
	
	
	
	
	/***********************************************************************************
		arg_line(?Arg_Id, ?Line).
		
		Is true when Line is an argumentation line for the argument identified
		with Arg_Id.
	************************************************************************************/
	
	arg_lines(Arg_Id,Lines):-
		findall([Arg_Id|L],(
			arg_lines([],[Arg_Id],Lines),
			member(L,Lines)
		),Lines).
	
	arg_lines(Friends,Enemies,Lines):-
		defeating_arg_lines(Friends, Enemies, Lines).
	
	arg_lines(Friends,Enemies,Lines):-
		blocking_arg_lines(Friends, Enemies, Lines).
	
	is_coherent_with(Defeater, Friends):-
		forall(member(F,Friends),(
			Defeater \= F,
			not((
				argument_id(F,Arg_F),
				argument_id(Defeater, Arg_D),
				in_conflict(Arg_F,Arg_D)
			))
		)).
	
	defeating_arg_lines(Friends,[Enemy|Enemies],Lines_List):-
		setof([Defeater|L],(
			defeats(Defeater,Enemy),
			is_coherent_with(Defeater,Friends),
			arg_lines([Enemy|Enemies], [Defeater|Friends], Lines),
			member(L,Lines)
		),Lines_List).
	
	defeating_arg_lines(Friends,[Enemy|_],[[]]):-
		not((defeats(Defeater,Enemy), is_coherent_with(Defeater,Friends))),
		not((blocks(Defeater,Enemy), is_coherent_with(Defeater,Friends))).
		
		
	blocking_arg_lines(Friends,[Enemy|Enemies],Lines_List):-
		setof([Defeater|L],(
			blocks(Defeater,Enemy),
			is_coherent_with(Defeater,Friends),
			defeating_arg_lines([Enemy|Enemies], [Defeater|Friends], Lines),
			member(L,Lines)
		),Lines_List).
		
	
	blocking_arg_lines(Friends,[Enemy|_],[[]]):-
		not((blocks(Defeater,Enemy), is_coherent_with(Defeater,Friends))).
	
	
	/***********************************************************************************
		is_exhaustive(+Line, +Lines).
		
		Is true when Line is an exhaustive argumentation line w.r.t. the other lines in
		Lines.
	************************************************************************************/
	
	is_exhaustive(Line,Lines):-
		not((member(OtherLine, Lines), OtherLine \= Line, prefix(Line,OtherLine))).
	
		
	
	/***********************************************************************************
		dialectical_tree(?Arg_Id, ?Tree).
		
		Is true when Tree is a dialectical tree for the argument identified with Arg_Id.
		
		Tree = (Root, [Child_1_Subtree, .. ,Child_N_Subtree])
		Child_N_Subtree = (Child_N, [Child_N1_Subtree, .. ,Child_NN_Subtree])
	************************************************************************************/
	
	
	dialectical_tree(Arg_Id,Tree):-
		argument(Arg_Id,_,_,_),
		dialectical_tree(Arg_Id,Arg_Id,[Arg_Id],Tree).
	
	
	dialectical_tree(Arg_Id,Root_Id,Root_Line,(Arg_Id,SubTrees)):-
		dtree_node_children(Root_Id,Root_Line,Children),
		findall(Tree,(
			member(C_Id,Children),
			append(Root_Line,[C_Id],New_Line),
			dialectical_tree(C_Id,Root_Id,New_Line,Tree)
		),SubTrees).
		
		
	
	%Search for the children of a node according to the current Root_Line.
	dtree_node_children(Root_Id,Root_Line,Children):-
		findall(Child_Id,(
			exhaustive_arg_line(Root_Id,Line),
			append(Root_Line,[Child_Id|_],Line)		% if append(L1,L2,L3) then prefix(L1,L3)
		), Aux),
		list_to_set(Aux,Children).
		
	
	
	/***********************************************************************************
		defeated(?Structure, +Tree).
		
		Defines wheter an argumental structure Structure is defeated contemplating
		its dialectival tree. For us, Structure is defeated when all its defeaters
		are undefeated.
	************************************************************************************/
	defeated(Arg_Id,(Arg_Id,SubTrees)):-
		children(Defeaters,Arg_Id,(Arg_Id,SubTrees)),
		Arg_Id \= null,
		member(Defeater,Defeaters),
		subtree((Defeater,DefeaterTrees),(Arg_Id, SubTrees)),
		undefeated(Defeater,(Defeater, DefeaterTrees)),!.
	
	
	/***********************************************************************************
		undefeated(?Structure, +Tree).
		
		Defines wheter an argumental structure Structure is undefeated contemplating 
		its dialectival tree. For us, Structure is undefeated when all its defeaters
		are defeated.
	************************************************************************************/
	undefeated(Arg_Id,(Arg_Id,[])):-!.
	
	undefeated(Arg_Id,(Arg_Id,SubTrees)):-
		children(Defeaters,Arg_Id,(Arg_Id,SubTrees)),
		Arg_Id \= null,
		forall(member(Defeater,Defeaters),(
			subtree((Defeater,DefeaterTrees),(Arg_Id, SubTrees)),
			defeated(Defeater,(Defeater, DefeaterTrees))
		)).
	
	
	marked_dtree(Arg_Id, Tree, undefeated):-
		undefeated(Arg_Id, Tree),!.
	
	
	marked_dtree(_, _, defeated).
	
	
	/***********************************************************************************
		warranted(?Claim).
		
		Defines wheter Claim is warranted.
	************************************************************************************/
	warranted(Claim):-
		argument(Id,_,_,Claim),
		m_dialectical_tree(Id, _Tree, undefeated).

	
	/***********************************************************************************
		justification(?Claim, ?Claim_U_Trees, ?NoClaim_U_Trees, ?BothClaim_D_Trees).
		
		Defines the set of dialectical that justify the warranty status of the claim
		Claim. Claim_U_Trees is the set of undefeated dialectical in favour of Claim.
		NoClaim_U_Trees is the set of undefeated dialectical against Claim.
		BothClaim_D_Trees is the set of defeated dialectical trees, both, in favour and
		against Claim.
	************************************************************************************/
	justification(Claim, Claim_U_Trees, NoClaim_U_Trees, BothClaim_D_Trees):-		
		findall(Node_Id, (
			argument(Arg_Id,_,_,Claim),
			dtree_node(Node_Id, null, _, Arg_Id, 'U')
		), Aux_1),
		
		list_to_set(Aux_1,Claim_U_Trees),
		
		findall(Node_Id, (
			complement(Claim,No_Claim),
			ArgA =.. [argument,_,_,_,Claim], call(ArgA),
			ArgB =.. [argument,Arg_Id_2,_,_,No_Claim], call(ArgB),
			dtree_node(Node_Id, null, _, Arg_Id_2, 'U')
		), Aux_2),
		
		list_to_set(Aux_2,NoClaim_U_Trees),
		
		findall(Node_Id, (
			argument(Arg_Id,_,_,Claim),
			dtree_node(Node_Id, null, _, Arg_Id, 'D')
		), Claim_D_Trees),
		
		
		findall(Node_Id, (
			complement(Claim,No_Claim),
			ArgA =.. [argument,_,_,_,Claim], call(ArgA),
			ArgB =.. [argument,Arg_Id_2,_,_,No_Claim], call(ArgB),
			dtree_node(Node_Id, null, _, Arg_Id_2, 'D')
		), NoClaim_D_Trees),
		
			
		append(Claim_D_Trees, NoClaim_D_Trees, Aux_3),
		
		list_to_set(Aux_3,BothClaim_D_Trees).
	
	
	% ============================================================================
	%				Predicates to execute the framework.		
	% ============================================================================	
	
	
	generate_warranted_conclusions:-
		remove_warranted_conclusions,
		
		generate_arguments,
		
		generate_argumentation_lines,
		generate_marked_dialectical_trees,
		
		%warranted_conclusion(Claim) is defined above and it is dynamic.
		
		retractall(exhaustive_arg_line(_,_)).
		
		
		
	generate_argumentation_lines:-
		forall((
			argument(Id,_,_,_),
			arg_lines(Id,Lines),
			member(L,Lines),
			is_exhaustive(L,Lines)
		),assert(exhaustive_arg_line(Id, L))).
	
	
	
	generate_marked_dialectical_trees:-
		retractall(m_dialectical_tree(_,_,_)),
		
		forall((
			argument(Id,_,_,_),
			dialectical_tree(Id,Tree)
		),(
			marked_dtree(Id, Tree, Status),
			assert(m_dialectical_tree(Id, Tree, Status))
		)).
		
	
	
	remove_warranted_conclusions:-
		retractall(m_dialectical_tree(_,_,_)).
		
	
	
	generate_dtree_nodes:-
		reset_id(dtree_node),
		retractall(dtree_node(_,_,_,_,_)),
		
		forall(m_dialectical_tree(_,Tree,_), assert_dtree_nodes(Tree,null)).
		
	
	
	assert_dtree_nodes(Dtree,null):-
		next_id(dtree_node,Node_Id),
		Dtree = (Arg_Id,Subtrees), 
		findall(Child_Id,(member(ST, Subtrees),assert_dtree_nodes(ST,Node_Id,Child_Id)),Children),
		node_status(Children,Status),
		assert(dtree_node(Node_Id,null,Children,Arg_Id,Status)).
		
	assert_dtree_nodes(Dtree,Father,Node_Id):-
		next_id(dtree_node,Node_Id),
		Dtree = (Arg_Id,Subtrees),
		findall(Child_Id,(member(ST, Subtrees),assert_dtree_nodes(ST,Node_Id,Child_Id)),Children),
		node_status(Children,Status),
		assert(dtree_node(Node_Id,Father,Children,Arg_Id,Status)),!.
		
	
	%If every child of a node N is marked as U, then N is marked as D.		
	node_status(Children_Ids, 'D'):-
		member(Child_Id,Children_Ids),
		dtree_node(Child_Id,_,_,_,'U'),!.
		
	node_status(_,'U').
		
	