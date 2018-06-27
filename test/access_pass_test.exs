defmodule AccessPassTest do
  use ExUnit.Case
  alias AccessPass.{RefreshToken, AccessToken, TestHelpers}
  doctest AccessPass

  test "add refresh adds a new refresh token and access token" do
    TestHelpers.clear()
    map = RefreshToken.add("uniq", %{}, 0)
    assert map |> TestHelpers.isMap() == true
  end

  test "add refresh with junk data fails" do
    TestHelpers.clear()
    err = RefreshToken.add("uniq", %{}, "abc")
    assert err |> TestHelpers.isErrorTup() == true
  end

  test "revoke removes both refresh token and access token" do
    TestHelpers.clear()
    map = RefreshToken.add("uniq", %{}, 0)
    access_token = map.access_token
    refresh_token = map.refresh_token
    assert RefreshToken.refresh(refresh_token) |> TestHelpers.isOkTup() == true
    assert AccessToken.check(access_token) |> TestHelpers.isOkTup() == true
    assert RefreshToken.revoke(refresh_token)
    assert AccessToken.check(access_token) |> TestHelpers.isErrorTup() == true
    assert RefreshToken.refresh(refresh_token) |> TestHelpers.isErrorTup() == true
  end

  test "revoke refresh with junk data fails" do
    TestHelpers.clear()
    assert RefreshToken.refresh(124) |> TestHelpers.isErrorTup() == true
    assert RefreshToken.refresh([123]) |> TestHelpers.isErrorTup() == true
    assert RefreshToken.refresh(%{}) |> TestHelpers.isErrorTup() == true
    assert RefreshToken.refresh({"one", "two"}) |> TestHelpers.isErrorTup() == true
    assert RefreshToken.refresh(nil) |> TestHelpers.isErrorTup() == true
  end

  test "refresh returns a new access token and adds it to access token store" do
    TestHelpers.clear()
    map = RefreshToken.add("uniq", %{}, 0)
    access_token = map.access_token
    refresh_token = map.refresh_token
    assert AccessToken.check(access_token) |> TestHelpers.isOkTup() == true
    assert {:ok, new_token} = RefreshToken.refresh(refresh_token)
    assert AccessToken.check(new_token) |> TestHelpers.isOkTup() == true
  end

  test "refresh with junk data fails" do
    TestHelpers.clear()
    assert RefreshToken.refresh(123) |> TestHelpers.isErrorTup() == true
    assert RefreshToken.refresh("123") |> TestHelpers.isErrorTup() == true
    assert RefreshToken.refresh([123]) |> TestHelpers.isErrorTup() == true
    assert RefreshToken.refresh(%{}) |> TestHelpers.isErrorTup() == true
    assert RefreshToken.refresh({"one", "two"}) |> TestHelpers.isErrorTup() == true
    assert RefreshToken.refresh(nil) |> TestHelpers.isErrorTup() == true
  end

  test "revoke self only on refresh only removes refresh token but leaves access token active" do
    TestHelpers.clear()
    map = RefreshToken.add("uniq", %{}, 0)
    access_token = map.access_token
    refresh_token = map.refresh_token
    assert AccessToken.check(access_token) |> TestHelpers.isOkTup()
    assert RefreshToken.refresh(refresh_token) |> TestHelpers.isOkTup()
    assert RefreshToken.revoke_self_only(refresh_token)
    :timer.sleep(500)
    assert RefreshToken.refresh(refresh_token) |> TestHelpers.isErrorTup()
    assert AccessToken.check(access_token) |> TestHelpers.isOkTup()
  end

  test "revoke self refresh with junk data fails" do
    TestHelpers.clear()
    # revoke self is a cast so always should return :ok
    assert RefreshToken.revoke_self_only(123) == :ok
    assert RefreshToken.revoke_self_only("123") == :ok
    assert RefreshToken.revoke_self_only([123]) == :ok
    assert RefreshToken.revoke_self_only(%{}) == :ok
    assert RefreshToken.revoke_self_only({"one", "two"}) == :ok
    assert RefreshToken.revoke_self_only(nil) == :ok
  end

  test "setting expire at will revoke both access token and refresh token at expired time" do
    TestHelpers.clear()
    map = RefreshToken.add("uniq", %{}, 2)
    access_token = map.access_token
    refresh_token = map.refresh_token
    assert AccessToken.check(access_token) |> TestHelpers.isOkTup() == true
    assert RefreshToken.refresh(refresh_token) |> TestHelpers.isOkTup() == true
    :timer.sleep(3000)
    assert AccessToken.check(access_token) |> TestHelpers.isErrorTup() == true
    assert RefreshToken.refresh(refresh_token) |> TestHelpers.isErrorTup() == true
  end

  test "expire as junk not number fails" do
    TestHelpers.clear()
    assert RefreshToken.add("uniq", %{}, "junk") |> TestHelpers.isErrorTup() == true
    assert RefreshToken.add("uniq", %{}, [123]) |> TestHelpers.isErrorTup() == true
    assert RefreshToken.add("uniq", %{}, %{}) |> TestHelpers.isErrorTup() == true
    assert RefreshToken.add("uniq", %{}, {"one", "two"}) |> TestHelpers.isErrorTup() == true
    assert RefreshToken.add("uniq", %{}, nil) |> TestHelpers.isErrorTup() == true
  end

  test "add should add a token with the registered meta" do
    TestHelpers.clear()
    assert map = RefreshToken.add("uniq", %{}, 2)
    refresh_token = map.refresh_token
    assert new_token = AccessToken.add(refresh_token, %{test: "this is test data"})
    assert {:ok, access_key_map} = AccessToken.check(new_token)
    assert Map.has_key?(access_key_map, :test) == true
  end

  test "revoke should revoke both access token and refresh token given an access token" do
    TestHelpers.clear()
    assert map = RefreshToken.add("uniq", %{}, 2)
    refresh_token = map.refresh_token
    access_token = map.access_token
    assert AccessToken.check(access_token) |> TestHelpers.isOkTup() == true
    assert RefreshToken.refresh(refresh_token) |> TestHelpers.isOkTup() == true
    AccessToken.revoke(access_token)
    assert AccessToken.check(access_token) |> TestHelpers.isErrorTup() == true
    assert RefreshToken.refresh(refresh_token) |> TestHelpers.isErrorTup() == true
  end

  test "check should return the object for an access token" do
    TestHelpers.clear()
    assert map = RefreshToken.add("uniq", %{test: "tester"}, 0)
    assert access_token = map.access_token
    assert {:ok, new_map} = AccessToken.check(access_token)
    assert Map.has_key?(new_map, :test) == true
  end

  test "check with junk data fails" do
    TestHelpers.clear()
    assert AccessToken.check("junk") |> TestHelpers.isErrorTup() == true
    assert AccessToken.check(123) |> TestHelpers.isErrorTup() == true
    assert AccessToken.check([123]) |> TestHelpers.isErrorTup() == true
    assert AccessToken.check(%{}) |> TestHelpers.isErrorTup() == true
    assert AccessToken.check({"one", "two"}) |> TestHelpers.isErrorTup() == true
    assert AccessToken.check(nil) |> TestHelpers.isErrorTup() == true
  end

  test "revoke self access on access should only revoke an access token while refresh token is still active" do
    TestHelpers.clear()
    assert map = RefreshToken.add("uniq", %{test: "tester"}, 0)
    assert refresh_token = map.refresh_token
    assert access_token = map.access_token
    assert AccessToken.check(access_token) |> TestHelpers.isOkTup() == true
    assert RefreshToken.refresh(refresh_token) |> TestHelpers.isOkTup() == true
    AccessToken.revoke_self_only(refresh_token)
    :timer.sleep(500)
    assert AccessToken.check(access_token) |> TestHelpers.isErrorTup() == true
    assert RefreshToken.refresh(refresh_token) |> TestHelpers.isOkTup() == true
  end

  test "access token is revoked after 10 seconds(in test config) but not refresh token" do
    TestHelpers.clear()
    assert map = RefreshToken.add("uniq", %{test: "tester"}, 0)
    assert access_token = map.access_token
    assert refresh_token = map.refresh_token
    assert AccessToken.check(access_token) |> TestHelpers.isOkTup() == true
    :timer.sleep(4000)
    assert AccessToken.check(access_token) |> TestHelpers.isOkTup() == true
    :timer.sleep(1000)
    assert AccessToken.check(access_token) |> TestHelpers.isErrorTup() == true
    assert RefreshToken.refresh(refresh_token) |> TestHelpers.isOkTup()
  end
end
