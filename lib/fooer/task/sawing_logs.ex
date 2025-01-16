defmodule Fooer.Task.SawingLogs do
  use DaedalRemote.Task

  @batch_interval 500

  @impl DaedalRemote.Task
  def setup(count) when count > 0 do
    {:ok, count}
  end

  @impl DaedalRemote.Task
  def run(count) do
    for {n, _} <- with_interval(1..count, @batch_interval) do
      # log as info, these are shipped back to the monitoring DaedalRemote.Task
      Logger.info("Sawing logs: #{n}", n: n)
      # Report progress
      progress({n, count})
    end

    {:ok, count}
  end

  @impl DaedalRemote.Task
  def teardown(_reason, progress, result) do
    {:ok, {progress, result}}
  end

  defp with_interval(enum, interval) do
    Stream.zip(enum, Stream.interval(interval))
  end
end
