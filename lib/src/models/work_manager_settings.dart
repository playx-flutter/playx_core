class WorkManagerSettings {
  /// Number of isolates to spawn
  final int? isolatesCount;

  /// If true, it will spawn isolates dynamically
  final bool? dynamicSpawning;

  /// If true, it will create a WorkerManager instance on boot
  final bool initWorkerManager;

  const WorkManagerSettings({
    this.isolatesCount,
    this.dynamicSpawning,
    this.initWorkerManager = true,
  });
}
