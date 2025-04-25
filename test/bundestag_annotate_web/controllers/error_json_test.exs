defmodule BundestagAnnotateWeb.ErrorJSONTest do
  use BundestagAnnotateWeb.ConnCase, async: true

  test "renders 404" do
    assert BundestagAnnotateWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert BundestagAnnotateWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
