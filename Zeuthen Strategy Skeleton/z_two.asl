// Agent z_two in project Zeuthen Strategy.mas2j

//z_two is similar to z_one, and in fact, mostly copied and pasted (including this very text!). There is one important difference:
//A deal, defined as [[list],[list]], consists of two task allocations, one for each agent.
//Z_two uses the RIGHT list as its set, and the left list as Z_one's. You are free to define a deal in other ways, however.
//Depending on how you implement the Zeuthen strategy, you might end up adding functionalities to one agent and not to the other.
//Always make sure that when you copy and paste code from one agent to the other, that you make the necessary adjustments (such as
//switching which side the agent has to use).

//Hint: Jason is not widely used on the internet, so code examples mostly exist
//on the Jason site itself. However, the beliefs are mostly prolog: take examples
//from prolog code, then check on http://jason.sourceforge.net/api/ if their prolog
//equivalents exist.
//Further, you should not need to use the environment/java part of this code.
//You should be able to finish all assignments by adjusting z_one and z_two.

/* Initial beliefs and rules */
//I remember where the post office is.
postoffice(a).

//I remember the following routes and their cost:
//Unless you want to make a graph search algorithm (not recommended),
//these beliefs will likely be unused.
route(a,b,2).
route(a,c,3).
route(b,c,4).
route(b,d,6).
route(b,e,5).
route(e,f,4).
route(c,f,3).

//I know the costs of all sub-tasks. Keep in mind that every possible combination
//is written here: if you want to add more, you will have to write down all
//new possible costs.
//It is recommended to keep lists in alphabetic order. Jason does not see
//[b,c] as the same as [c,b]. This can cause bugs. If necessary, use the function
// .sort(List,SortedList) to make a list[c,b] a sorted list [b,c].
cost([],0).
cost([b],4).
cost([c],6).
cost([d],16).
cost([e],14).
cost([f],12).
cost([b,c],9).
cost([b,d],16).
cost([b,e],14).
cost([b,f],15).
cost([c,d],21).
cost([c,e],17).
cost([c,f],12).
cost([d,e],26).
cost([d,f],27).
cost([e,f],17).
cost([b,c,d],21).
cost([b,c,e],17).
cost([b,c,f],17).
cost([b,d,e],26).
cost([b,d,f],27).
cost([b,e,f],17).
cost([c,d,e],27).
cost([c,d,f],27).
cost([c,e,f],17).
cost([d,e,f],27).
cost([b,c,d,e],27).
cost([b,c,d,f],27).
cost([b,c,e,f],17).
cost([b,d,e,f],27).
cost([c,d,e,f],27).
cost([b,c,d,e,f],27).

//I remember my task set. During experiments, make sure to adjust the task.
// gets it from other agent
allTasks([b,c,d,e,f]).//all tasks are then implicit
//allTasks([ b,c,e,f]).


//HELPER
myName(z_two).
yourName(z_one).
iAmNotLazy.

mySide([A1,A2],A2).

//Checking if two task sets are indeed valid re-distribution. This code requires
// having the total task set (b,c,d,e,f for example). You will need a way for totalTask
//to get the total task set when agents need to calculate the total task set by themselves.
validDistribution(OneSide,OtherSide) :-
	allTasks(AllTasks)&
	checkTotalTask(OneSide,OtherSide,AllTasks) & //Adjust [b,c,d,e,f] with a totalTask belief later on in the assignment.
	uniqueSets(OneSide,OtherSide).

//Checking if the two task sets are indeed the total task. 
checkTotalTask(OneSide, OtherSide, Total) :- //true.
	.concat(OneSide, OtherSide, NewTotal) &
	.sort(NewTotal, SortedNewTotal) &
	SortedNewTotal == Total.


//Checking if two sets are unique. 
uniqueSets(OneSide, OtherSide) :- //true.
	.intersection(OneSide, OtherSide, Intersection) &
	Intersection == [].

getUtility(NT, OT, Utility) :-
	cost(OT, COT) &
	cost(NT, CNT) &
	Utility = COT - CNT.
	
//I know when a task is individual rational.
indiRatio(NT, OT) :- //true.
	getUtility(NT, OT, Utility) &
	Utility >= 0.
	
	
//I know when a deal is pareto optimal:
//Enter your code here. Consider adding more functions to solve this problem. For example, given a task, which addresses will the other agent have to do?
//Hint: .findall function might be useful here. (See below for details)
paretoOptimal(MySide, TheirSide) :- 
	originalTask(OT) &
	theirOriginalTask(TOT) &
	.findall(Allocation, findAllocation(Allocation, OT, TOT), SetOfAllocations) &
//	.print(SetOfAlloctions) &
	getUtility(MySide, OT, CMyUtility) &
	getUtility(TheirSide, TOT, CTheirUtility) &
	checkAllocations(SetOfAllocations, CMyUtility, CTheirUtility).
	
	
findAllocation([[MySide, MyUtility], [TheirSide, TheirUtility]], OT, TOT) :-
	cost(MySide, _) &
	cost(TheirSide, _) &
	validDistribution(MySide, TheirSide) &
	getUtility(MySide, OT, MyUtility) &
	getUtility(TheirSide, TOT, TheirUtility).
	

dominates(OldMyUtility, OldTheirUtility, NewMyUtility, NewTheirUtility) :-
	OldMyUtility > NewMyUtility &
	OldTheirUtility >= NewTheirUtility |
	OldMyUtility >= NewMyUtility &
	OldTheirUtility > NewTheirUtility.

checkAllocations([], _, _). 
checkAllocations([[[MySide, MyUtility], [TheirSide, TheirUtility]]|Rest], CMyUtility, CTheirUtility) :- 
	not dominates(MyUtility, TheirUtility, CMyUtility, CTheirUtility) &
	checkAllocations(Rest, CMyUtility, CTheirUtility).


//I know what conditions deal I can offer up for negotiations needs to fulfill.
//If you want to check if you did a part correct, for example, validDistribution,
//comment the other parts out. 
goodDeal([TheirSide,MySide]) :-
	cost(MySide,_) &
	cost(TheirSide,_) &
	validDistribution(MySide,TheirSide) &
	originalTask(OT) &
	theirOriginalTask(TOT) & //The agent should have received this info from the other agent.
	indiRatio(MySide,OT) & //I am not going to consider deals worse than the conflict deal.
	indiRatio(TheirSide,TOT) & //The other agent is always going to refuse deals worse than the conflict deal. No point in considering them.
	paretoOptimal(MySide,TheirSide).
	
//I can find all possible deals for negotiations.
setOfDeals(SetOfDeals) :-
	.findall(Deal, goodDeal(Deal),SetOfDeals).
	// The function .findall(Answer, belief(Nonsense,Answer), Answers) finds all
	//potential solutions to belief(Nonsense,Answer) and puts them in a list of Answers.
	//The first argument (Answer) states which part of the belief we want all solution of.
	//The second argument is the belief that we attempt to unify with the believes we have,
	//using the parameters 'Nonsense' and 'Answer'.
	//In this particular belief, we ask for all potential deals that are correct and put them
	//in the list SetOfDeals.
	
//I can sort a set of good deals so that the deals that are best for me, come first and slowly decline to less profitable deals.
sortedSet([[TheirSide,MySide]|OtherDeals],SetOfSortedDeals) :-
	sortSet(OtherDeals,[[TheirSide,MySide]|OtherDeals],[TheirSide,MySide],SetOfSortedDeals).

//I can sort a set of deals. This is accomplished using selection sort.
//No more deals left to try and sort. We are done.
sortSet([],[],_,SetOfSortedDeals) :- SetOfSortedDeals =[].
//Went through the list and found the lowest cost. Placing it on the spot, remove
//it from the to be sorted list, and continue with remainder.
sortSet([],ToBeSortedDeals,Deal,[X|Y]) :-
	X=Deal &
	.delete(Deal,ToBeSortedDeals,ToBeSorted) &
	sortSet(ToBeSorted,ToBeSorted,[],Y).
//Starting anew, assuming for now that lowest cost comes from the first deal in the list.
sortSet([Deal|OtherDeals],ToBeSorted,[],SetOfSortedDeals) :-
	sortSet(OtherDeals,ToBeSorted,Deal,SetOfSortedDeals).
//We found a deal with a lower cost: remembering it so we can compare it with the deals after it.
sortSet([[TheirSide,MySide]|OtherDeals],ToBeSorted,[CurTheirHigh,CurMyHigh],SetOfSortedDeals) :-
	cost(MySide,MyCheckCost) &
	cost(CurMyHigh,CurMyCost) &
	MyCheckCost < CurMyCost &
	sortSet(OtherDeals,ToBeSorted,[TheirSide,MySide],SetOfSortedDeals).
//No new deal with a lower cost, so our current assumed best remains the best for now.
sortSet([[TheirSide,MySide]|OtherDeals],ToBeSorted,CurBestDeal,SetOfSortedDeals) :-
	sortSet(OtherDeals,ToBeSorted,CurBestDeal,SetOfSortedDeals).

	
	
//Finding best deal
getBestDeal(MyBestDeal):-
	theSetOfNegotiationDeals([MyBestDeal|DealSet]) 
	.

//look for best utility
dealWithBestUtility(Deal,  [], Deal).
dealWithBestUtility([MyDeal1,TheirDeal1],  [[MyDeal2,TheirDeal2]|Rest], BestDeal):- 
	originalTask(OT) &
	getUtility(MyDeal1, OT, CMyUtility1) &
	getUtility(MyDeal2, OT, CMyUtility2) &
	CMyUtility2>CMyUtility1 &
	dealWithBestUtility([MyDeal2,TheirDeal2], Rest, BestDeal).
	
dealWithBestUtility([MyDeal1,TheirDeal1],  [[MyDeal2,TheirDeal2]|Rest], BestDeal):- 
	originalTask(OT) &
	getUtility(MyDeal1, OT, CMyUtility1) &
	getUtility(MyDeal2, OT, CMyUtility2) &
	dealWithBestUtility([MyDeal1,TheirDeal1], Rest, BestDeal).

	
//Risk

// proposed deal is coming from the other agent	
myWillingnessToRisk([_, MyDeal], [_, ProposedDeal], Risk) :-
	originalTask(OT) &
	getUtility(MyDeal, OT, MyUtility) & 
	getUtility(ProposedDeal, OT, ProposedUtility) & 
	Risk = (MyUtility - ProposedUtility)/(MyUtility) &
	.print("my WTR:frac{", MyUtility, "-", ProposedUtility, "}{", MyUtility , "}=", Risk).
	
// proposed deal is coming from the other agent	
// but we are calculating the WRisk for the other agent 
// so his perspective becomes my perspective
theirWillingnessToRisk([MyDeal, _], [ProposedDeal, _], Risk) :- 
	theirOriginalTask(TOT) & 
	getUtility(MyDeal, TOT, MyUtility) & 
	getUtility(ProposedDeal, TOT, ProposedUtility) & 
	Risk = (ProposedUtility - MyUtility)/(ProposedUtility) &
	.print("their WTR:frac{", MyUtility, "-", ProposedUtility, "}{", MyUtility , "}=", Risk).
	
	
getWillingnessToRisk(ProposedDeal, MyWillingness, TheirWillingness) :-
	myLastDeal(MyDeal) &
	myWillingnessToRisk(MyDeal, ProposedDeal, MyWillingness) &
	theirWillingnessToRisk(MyDeal, ProposedDeal, TheirWillingness)
.


checkAcceptance([ProposedTheirs, ProposedMine]) :-
	originalTask(OT)&
	myLastDeal([MyTheirs, MyMine])&
	getUtility(MyMine, OT, MyUtility) & 
	getUtility(ProposedMine, OT, TheirUtility) &
	TheirUtility>=MyUtility
.
checkAcceptance(_) :- fail.

	
findRiskChangingDeal([], _, _) :- fail.

// Proposed is coming from the other agent 
findRiskChangingDeal([MyDeal|Rest], ProposedDeal, MyDeal) :-
	myWillingnessToRisk(MyDeal, ProposedDeal, MyWillingness) &
	theirWillingnessToRisk(MyDeal, ProposedDeal, TheirWillingness) &
	MyDeal = [MyLeft, MyRight] &
	myLastDeal([LastLeftSide,_])&
	cost(MyLeft, CostNow) & 
	cost(LastLeftSide, CostLast) & 
	CostNow <= CostLast & 
	TheirWillingness <= MyWillingness &
	not used(MyDeal).
	
findRiskChangingDeal([MyDeal|Rest], ProposedDeal, FoundDeal) :-
	.print("recurse findRiskChangingDeal", MyDeal) &
	findRiskChangingDeal(Rest, ProposedDeal, FoundDeal) .
	


/* Initial goals */
//I hate the deal I have been given. I want a better one! Perhaps I can ask z_one...
!getBetterDeal.



/* Plans */
//Initial conversation with the other agent. If I do not know their Original Task,
//then I have not yet asked. So I will ask for that and remember their answer. I will show
//their original task to the user as well. After this, I find all good deals and sort them and
//print the answer to the user. I then wait for further negotiation.

//This function requires you to finish the beliefs the agent has. If you have completed
//everything correctly, then you should see the following pop up:
//Agent 2 offers following deals  [[[b,c,e,f],[d]],[[c,e,f],[b,d]],[[b,d],[c,e,f]],[[d],[b,c,e,f]],[[c,f],[b,d,e]]]
//This is the negotiation set: you completed the first part of the assignment.

//It is recommended to first finish negotiations when you get to this point. After,
//you will need to come back to this function to create a way to reason what the total
//task set is given originalTask and theirOriginalTask, as well converse about the costs and remember these.
+!getBetterDeal
	: not theirOriginalTask(Task)
	<-
	.send(z_one, askOne, originalTask(TheirTask), originalTask(Answer)); //Asking the other agent what their original task is.
	//Note that here, we only want the Answer, whereas this function would normally return 'originalTask(Answer)[source: z_one]
	//By specifying originalTask in the return, we can seperate Answer from the rest and make a new belief with it.
	+theirOriginalTask(Answer);
	.print("Agent 1's task is ", Answer);
	?allTasks(AllTasks);
	.difference(AllTasks, Answer, MyTask);
	+originalTask(MyTask);
	?setOfDeals(Deals); //Finding all good deals, but they are unsorted.
	?sortedSet(Deals,SortedSet); //All good deals are now sorted.
	.print("Agent 2 offers following deals ", SortedSet);
	+theSetOfNegotiationDeals(SortedSet); //Remember the current negotiation deals.
	?getBestDeal(BestDeal);
	.print("My initial offer is: ", BestDeal);
	+myLastDeal(BestDeal);
	?yourName(OtherAgent);
	.send(OtherAgent, tell, ready);
	 // wait so other agent has time to set everything up
	if(ready){
	.print("ready already")
	}else{
	.wait({+ready});
	}
	.send(OtherAgent, achieve, whoStarts(BestDeal))
.


+myLastDeal(Deal)
	<-
	+used(Deal)
.

	
////////////////////////// Negotiation /////////////////////////////

// Determine who should initially act
+!whoStarts(ProposedDeal)
	:
	iAmLazy &
	getWillingnessToRisk(ProposedDeal, MyWillingness, TheirWillingness) &
	MyWillingness < TheirWillingness // I have to act so do it!
	<-
	!theirProposal(ProposedDeal)
.


+!whoStarts(ProposedDeal)
	:
	iAmLazy // Other agent will act
	<-
	-iAmLazy
.

+!whoStarts(ProposedDeal)
	<-
	!theirProposal(ProposedDeal) // I am not lazy so act!
.
// END



+!theirProposal(ProposedDeal)
	:
	checkAcceptance(ProposedDeal)
	<- 
	?yourName(OtherAgent);
	.send(OtherAgent, tell, accept(ProposedDeal));
	+accept(ProposedDeal)
.


// less willing to risk but cannot find better deal that would change willingness to risk	
+!theirProposal(ProposedDeal)
	: 
	getWillingnessToRisk(ProposedDeal, MyWillingness, TheirWillingness) &
	MyWillingness < TheirWillingness &
	theSetOfNegotiationDeals(SortedSet) &
	not findRiskChangingDeal(SortedSet, ProposedDeal, _)
	<- 
	?yourName(OtherAgent);
	.print("1 My Risk: ", MyWillingness, " Their Risk: ",TheirWillingness, " Deal: ", ProposedDeal);
	.send(OtherAgent, tell, conflictDeal);
	+conflictDeal
.

	
+!theirProposal(ProposedDeal)
	: 
	getWillingnessToRisk(ProposedDeal, MyWillingness, TheirWillingness) &
	MyWillingness < TheirWillingness
	<- 
	?yourName(OtherAgent);
	.print("2 My Risk: ", MyWillingness, " Their Risk: ",TheirWillingness, " Deal: ", ProposedDeal);
	?theSetOfNegotiationDeals(SortedSet);
	?findRiskChangingDeal(SortedSet, ProposedDeal, CounterDeal);
	.print("making counter proposal", CounterDeal);
	.send(OtherAgent, achieve, theirProposal(CounterDeal)) ;
	-+myLastDeal(CounterDeal);
.


+!theirProposal(ProposedDeal)
	:
	getWillingnessToRisk(ProposedDeal, MyWillingness, TheirWillingness) &
	MyWillingness > TheirWillingness
	<- 
	//await new proposal
	.print("3 My Risk: ", MyWillingness, " Their Risk: ",TheirWillingness, " Deal: ", ProposedDeal);
	?myLastDeal(Deal);
	.print("awaiting counter proposal. My last proposal: ", Deal);
.

+!theirProposal(ProposedDeal)
	:
	getWillingnessToRisk(ProposedDeal, MyWillingness, TheirWillingness) &
	MyWillingness == TheirWillingness &
	.random(Coin) &
	.print("Flipping coin", Coin) &
	Coin <=0.5
	<- 
	//keep it my turn
	!coinChoseMe(ProposedDeal)
.


+!theirProposal(ProposedDeal)
	:
	getWillingnessToRisk(ProposedDeal, MyWillingness, TheirWillingness) &
	MyWillingness == TheirWillingness
	<- 
	?yourName(OtherAgent);
	?myLastDeal(Deal);
	.send(OtherAgent, achieve, coinChoseMe(Deal))
.

+!coinChoseMe(ProposedDeal)
	:
	checkAcceptance(ProposedDeal)
	<- 
	?yourName(OtherAgent);
	.send(OtherAgent, tell, accept(ProposedDeal));
	+accept(ProposedDeal)
.

+!coinChoseMe(ProposedDeal)
	:
	theSetOfNegotiationDeals(SortedSet) &
	not findRiskChangingDeal(SortedSet, ProposedDeal, _)
	<-
	?yourName(OtherAgent);
	.send(OtherAgent, tell, conflictDeal);
	+conflictDeal
.

+!coinChoseMe(ProposedDeal)
	<-
	?yourName(OtherAgent);
	?theSetOfNegotiationDeals(SortedSet);
	?findRiskChangingDeal(SortedSet, ProposedDeal, CounterDeal);
	.print("making counter proposal ", CounterDeal);
	.send(OtherAgent, achieve, theirProposal(CounterDeal)) ;
	-+myLastDeal(CounterDeal);
.

//////////////////////////Their Proposal End/////////////////////////////

+accept(Deal)
	<-
	.print("Deal Accepted: ", Deal);
	?mySide(Deal,D);
	?originalTask(OT);
	?getUtility(D,OT,U);
	.print("Utility for me: ", U,"  ",OT,"->", D)
.



+conflictDeal
	<-
	?originalTask(Task) ;
	.print("Conflict task: ", Task)
.
