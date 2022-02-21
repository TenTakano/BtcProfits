defmodule BtcProfits.CsvFormatter do
  @time_zone_diff_seconds 60 * 60 * 9

  def import_profit_sheet(path) do
    case import_lines(path, "\r\n") do
      {:ok, [_ | content]} ->
        result =
          Enum.map(content, &format_profit_sheet/1)
          |> Enum.reject(&(String.contains?(&1.type, "Withdraw") || &1.type == "Refund"))

        {:ok, result}

      _ ->
        :error
    end
  end

  def import_btc_price(path) do
    case import_lines(path, "\n") do
      {:ok, content} ->
        result =
          Enum.map(content, &format_btc_price_sheet/1)
          |> Enum.reject(&(&1 == nil))

        {:ok, result}

      _ ->
        :error
    end
  end

  defp import_lines(path, new_line) do
    case File.read(path) do
      {:ok, content} ->
        {:ok, String.split(content, new_line)}

      {:error, _} ->
        :error
    end
  end

  defp format_profit_sheet(line) do
    [timestamp, _coin, type, amount, _address, balance] = String.split(line, ",")
    [date, time, _timezone] = String.split(timestamp, " ")
    {:ok, datetime, _} = DateTime.from_iso8601("#{date}T#{String.pad_leading(time, 8, "0")}Z")

    %{
      time: DateTime.add(datetime, @time_zone_diff_seconds, :second),
      type: type,
      amount: String.to_float(amount),
      balance: String.to_float(balance)
    }
  end

  defp format_btc_price_sheet(line) do
    case String.split(line, ",") do
      [timestamp, _open, _high, _low, close, _value] ->
        {:ok, date} =
          String.split(timestamp, " ")
          |> List.first()
          |> Date.from_iso8601()

        %{
          date: date,
          price: String.to_integer(close)
        }

      _ ->
        nil
    end
  end
end
