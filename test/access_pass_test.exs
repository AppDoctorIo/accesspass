defmodule AccessPassTest do
  use ExUnit.Case
  alias AccessPass.{RefreshToken,AccessToken}
  @name :auth_cache
  doctest AccessPass
  def restartGen() do
    Supervisor.terminate_child(AccessPass.Supervisor, AccessPass.TokenSupervisor)
    Supervisor.restart_child(AccessPass.Supervisor,AccessPass.TokenSupervisor)
    {:ok} 
  end
  def isMap(map) when is_map(map), do: true
  def isMap(map), do: false 
  def isErrorTup({:error,_}), do: true
  def isErrorTup(_), do: false
  def isOkTup({:ok,_}), do: true
  def isOkTup(_), do: false 
  test "add refresh adds a new refresh token and access token" do
    restartGen()
    map = RefreshToken.add("uniq",%{},0)
    assert map |> isMap == true
  end 
  test "add refresh with junk data fails" do
    restartGen()
    err = RefreshToken.add("uniq",%{},"abc")
    assert err |> isErrorTup == true
  end
  test "revoke removes both refresh token and access token" do
    restartGen()
    map = RefreshToken.add("uniq",%{},0)
    access_token = map.access_token
    refresh_token = map.refresh_token
    assert RefreshToken.refresh(refresh_token) |> isOkTup == true
    assert AccessToken.check(access_token) |> isOkTup == true
    assert RefreshToken.revoke(refresh_token)
    assert AccessToken.check(access_token) |> isErrorTup == true
    assert RefreshToken.refresh(refresh_token) |> isErrorTup == true
  end
  test "revoke refresh with junk data fails" do
    restartGen()
    assert RefreshToken.refresh(124) |> isErrorTup == true
    assert RefreshToken.refresh([123]) |> isErrorTup == true
    assert RefreshToken.refresh(%{}) |> isErrorTup == true
    assert RefreshToken.refresh({"one","two"}) |> isErrorTup == true
    assert RefreshToken.refresh(nil) |> isErrorTup == true
    
  end
  test "refresh returns a new access token and adds it to access token store" do
    restartGen()
    map = RefreshToken.add("uniq",%{},0)
    access_token = map.access_token
    refresh_token = map.refresh_token
    assert AccessToken.check(access_token) |> isOkTup == true
    assert {:ok,new_token} = RefreshToken.refresh(refresh_token)
    assert AccessToken.check(new_token) |> isOkTup == true
  end
  test "refresh with junk data fails" do
    restartGen()
    assert RefreshToken.refresh(123) |> isErrorTup == true
    assert RefreshToken.refresh("123") |> isErrorTup == true
    assert RefreshToken.refresh([123]) |> isErrorTup == true
    assert RefreshToken.refresh(%{}) |> isErrorTup == true
    assert RefreshToken.refresh({"one","two"}) |> isErrorTup == true
    assert RefreshToken.refresh(nil) |> isErrorTup == true
  end
  test "revoke self only on refresh only removes refresh token but leaves access token active" do
    restartGen()
    map = RefreshToken.add("uniq",%{},0)
    access_token = map.access_token
    refresh_token = map.refresh_token
    assert AccessToken.check(access_token) |> isOkTup
    assert RefreshToken.refresh(refresh_token) |> isOkTup
    assert RefreshToken.revoke_self_only(refresh_token)
    assert RefreshToken.refresh(refresh_token) |> isErrorTup
    assert AccessToken.check(access_token) |> isOkTup
    
  end
  test "revoke self refresh with junk data fails" do
    restartGen()
    
  end
  test "setting expire at will revoke but access token and refresh token at expired time" do
    restartGen()
    
  end
  test "expire as junk not number fails" do
    restartGen()
    
  end
  test "add should add a token with the registered meta" do
    restartGen()
    
  end
  test "add with junk data fails" do
    restartGen()
    
  end
  test "revoke should revoke both access token and refresh token given an access token" do
    restartGen()

  end
  test "revoke access with junk data fails" do
    restartGen()
    
  end
  test "check should return the object for an access token" do
    restartGen()
    
  end
  test "check with junk data fails" do
    restartGen()
    
  end
  test "revoke self access on access should only revoke an access token while refresh token is still active" do
    restartGen()
    
  end
  test "revoke self with junk data fails" do
    restartGen()
    
  end
  test "access token is revoked after 30 seconds(in test config)" do
    restartGen()

  end
  test "not a number as refresh fails correctly" do
    restartGen()
    
  end
end
