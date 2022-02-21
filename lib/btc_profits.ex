defmodule BtcProfits do
  alias BtcProfits.CsvFormatter

  def process(profit_sheet_path, btc_price_path) do
    with(
      {:ok, profits} <- CsvFormatter.import_profit_sheet(profit_sheet_path),
      {:ok, prices} <- CsvFormatter.import_btc_price(btc_price_path)
    ) do
      profits_with_price = combine(profits, prices)

      %{
        fx_profits: total_realized_profit(profits_with_price),
        sell: sell_value_price(profits_with_price),
        buy: buy_value_price(profits_with_price)
      }
    else
      _ -> IO.inspect("error")
    end
  end

  defp combine(profits, prices) do
    Enum.map(profits, fn line ->
      %{price: price} = Enum.find(prices, &(&1.date == DateTime.to_date(line.time)))
      Map.put(line, :price, price)
    end)
  end

  defp total_realized_profit(profits_with_price) do
    profits_with_price
    |> Enum.reject(&(&1.type == "Deposit"))
    |> Enum.reduce(0, fn %{amount: amount, price: price}, acc ->
      acc + amount * price
    end)
  end

  defp sell_value_price(profits_with_price) do
    {value, loss} =
      profits_with_price
      |> Enum.filter(&(&1.type == "Realized P&L" && &1.amount < 0))
      |> Enum.reduce({0, 0}, fn %{amount: amount, price: price}, {acc_value, acc_loss} ->
        {acc_value + amount, acc_loss + amount * price}
      end)

    %{value: value, loss: loss}
  end

  defp buy_value_price(profits_with_price) do
    {value, total_cost} =
      profits_with_price
      |> Enum.filter(&(&1.type != "Deposit" && &1.amount > 0))
      |> Enum.reduce({0, 0}, fn %{amount: amount, price: price}, {acc_value, acc_cost} ->
        {acc_value + amount, acc_cost + amount * price}
      end)

    %{value: value, average_cost: total_cost / value}
  end
end
