defmodule Blinker.LED do
  @moduledoc false

  alias Circuits.GPIO

  @doc """
  ## Examples
  ```
  alias Blinker.LED

  LED.open(26)
  |> LED.on()
  |> tap(fn _ -> Process.sleep(500) end)
  |> LED.off()
  ```
  """
  def open(pin) do
    message("Opening #{pin}")

    {:ok, led} = GPIO.open(pin, :output)
    led
  end

  def switch(led, true), do: on(led)
  def switch(led, false), do: off(led)

  def on(led) do
    message("on #{inspect(led)}")

    GPIO.write(led, 1)
    led
  end

  def off(led) do
    message("off #{inspect(led)}")

    GPIO.write(led, 0)
    led
  end

  def message(message) do
    # IO.puts in hardware can be unpredictable
    IO.puts(message)
  end
end
