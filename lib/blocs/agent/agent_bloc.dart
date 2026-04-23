import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/i_agent_repository.dart';
import 'agent_event.dart';
import 'agent_state.dart';

class AgentBloc extends Bloc<AgentEvent, AgentState> {
  final IAgentRepository _agentRepository;

  AgentBloc({required IAgentRepository agentRepository})
      : _agentRepository = agentRepository,
        super(const AgentInitial()) {
    on<AgentsFetchRequested>(_onFetch);
    on<AgentActivateRequested>(_onActivate);
  }

  Future<void> _onFetch(
    AgentsFetchRequested event,
    Emitter<AgentState> emit,
  ) async {
    emit(const AgentLoading());
    try {
      final agents = await _agentRepository.getAllAgents(token: event.token);
      emit(AgentLoaded(agents));
    } catch (e) {
      emit(AgentError(_extractMessage(e)));
    }
  }

  Future<void> _onActivate(
    AgentActivateRequested event,
    Emitter<AgentState> emit,
  ) async {
    try {
      final agent = await _agentRepository.getAgent(
        agentId: event.agentId,
        token: event.token,
      );
      if (agent != null) {
        final currentAgents =
            state is AgentLoaded ? (state as AgentLoaded).agents : <Agent>[];
        final updated = currentAgents
            .map((a) => a.id == agent.id ? agent : a)
            .toList();
        emit(AgentLoaded(updated));
      }
    } catch (e) {
      emit(AgentError(_extractMessage(e)));
    }
  }

  String _extractMessage(Object e) {
    final msg = e.toString();
    const prefix = 'Exception: ';
    if (msg.startsWith(prefix)) return msg.substring(prefix.length);
    return msg;
  }
}
