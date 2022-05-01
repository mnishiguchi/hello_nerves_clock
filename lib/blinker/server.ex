defmodule Blinker.Server do
  @moduledoc """
  A service layer that controls timing and tracks the state of a blinking LED.

  ## Examples
  ```
  Blinker.Server.start_link
  GenServer.stop(Blinker.Server)

  Blinker.Server.start_link(on_time_ms: 500, off_time_ms: 1000)
  GenServer.stop(Blinker.Server)
  ```
  """

  use GenServer

  defstruct [
    :led_ref,
    :led_on,
    :on_time_ms,
    :off_time_ms
  ]

  @default_pin 26
  @default_off_time_ms 500
  @default_on_time_ms 1000

  defp new_state(opts) do
    %__MODULE__{
      led_on: false,
      led_ref: Blinker.LED.open(opts[:pin] || @default_pin),
      off_time_ms: opts[:off_time_ms] || @default_off_time_ms,
      on_time_ms: opts[:on_time_ms] || @default_on_time_ms
    }
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(opts \\ []) do
    send(self(), :tick)

    {:ok, new_state(opts)}
  end

  @impl GenServer
  def handle_info(:tick, state) do
    {:noreply,
     state
     |> toggle_led!()
     |> schedule_next_tick!()}
  end

  defp toggle_led!(state) do
    state
    |> struct!(led_on: !state.led_on)
    |> sync_led!()
  end

  defp sync_led!(state) do
    Blinker.LED.switch(state.led_ref, state.led_on)
    state
  end

  defp schedule_next_tick!(state) do
    Process.send_after(self(), :tick, wait_time_ms(state))
    state
  end

  defp wait_time_ms(%{led_on: true} = state), do: state.on_time_ms
  defp wait_time_ms(%{led_on: false} = state), do: state.off_time_ms
end
