import 'package:equatable/equatable.dart';

import '../../data/models/agent.dart';

abstract class AgentState extends Equatable {
  const AgentState();

  @override
  List<Object?> get props => [];
}

class AgentInitial extends AgentState {
  const AgentInitial();
}

class AgentLoading extends AgentState {
  const AgentLoading();
}

class AgentLoaded extends AgentState {
  final List<Agent> agents;
  const AgentLoaded(this.agents);

  @override
  List<Object?> get props => [agents];
}

class AgentError extends AgentState {
  final String message;
  const AgentError(this.message);

  @override
  List<Object?> get props => [message];
}
