import 'package:equatable/equatable.dart';

abstract class AgentEvent extends Equatable {
  const AgentEvent();

  @override
  List<Object?> get props => [];
}

class AgentsFetchRequested extends AgentEvent {
  final String? token;
  const AgentsFetchRequested({this.token});

  @override
  List<Object?> get props => [token];
}

class AgentActivateRequested extends AgentEvent {
  final String agentId;
  final String? token;
  const AgentActivateRequested({required this.agentId, this.token});

  @override
  List<Object?> get props => [agentId, token];
}
