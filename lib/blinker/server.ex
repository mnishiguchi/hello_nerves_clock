defmodule Blinker.Server do
  @moduledoc """
  ## Examples
  ```
  Blinker.Server.start_link

  GenServer.stop(Blinker.Server)
  ```
  """

  use GenServer

  alias Blinker.LED

  defstruct [:led, :on, :ticker]

  @default_pin 26

  defp new_state(opts) do
    %__MODULE__{
      # current LED state
      on: false,
      # reference to a hardware GPIO pin
      led: LED.open(opts[:pin] || @default_pin),
      # a function that send the next blink
      ticker: opts[:ticker] || &wait_one_second/0
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
    state.ticker.()

    {:noreply, toggle_led(state)}
  end

  defp toggle_led(%{on: on} = state) do
    next_led_state = !on
    LED.switch(state.led, next_led_state)

    %{state | on: next_led_state}
  end

  defp wait_one_second do
    Process.send_after(self(), :tick, 1000)
  end
end
