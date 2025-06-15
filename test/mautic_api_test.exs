defmodule MauticApiTest do
  use ExUnit.Case
  doctest MauticApi

  test "get contact 1" do
    assert {:ok, %{"contact" => %{"id" => 1}}} = MauticApi.get_contact(1)
  end
end
