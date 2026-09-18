// Legacy forwarding path retained so any local work that still imports the
// old `data/repos` location does not break. The interface itself belongs to
// the domain layer and has one canonical declaration.
export '../../domain/repositories/auth_repository.dart';
