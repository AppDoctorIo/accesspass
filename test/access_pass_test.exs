defmodule AccessPassTest do
  use ExUnit.Case
  @name :auth_cache
  doctest AccessPass

  test "should add user" do
    GenServer.call(@name, {:clear})
    assert AccessPass.add("jordad", true) == {:ok, true}
  end

  test "count is working" do
    GenServer.call(@name, {:clear})
    assert AccessPass.count() == 0
    assert AccessPass.add("jordan", true) == {:ok, true}
    assert AccessPass.count() == 1
  end

  test "should not overwrite when add is called again" do
    GenServer.call(@name, {:clear})
    assert AccessPass.add("noOverwrite", true) == {:ok, true}
    assert AccessPass.add("noOverwrite", false) == {:ok, true}
    assert AccessPass.logged?("noOverwrite") == {:ok, true}
  end

  test "should revoke token" do
    GenServer.call(@name, {:clear})
    assert AccessPass.add("revokeTest", true) == {:ok, true}
    assert AccessPass.logged?("revokeTest") == {:ok, true}
    assert AccessPass.revoke("revokeTest") == :ok
    assert AccessPass.logged?("revokeTest") == :error
  end

  test "should revoke token after 2 seconds" do
    GenServer.call(@name, {:clear})
    assert AccessPass.add("revokeAtTest", true, 1) == {:ok, true}
    assert AccessPass.logged?("revokeAtTest") == {:ok, true}
    :timer.sleep(1500)
    assert AccessPass.logged?("revokeAtTest") == :error
  end

  test "returns all state" do
    GenServer.call(@name, {:clear})
    assert AccessPass.add("allTest", true, 1) == {:ok, true}
    assert AccessPass.add("allTest2", 2, 1) == {:ok, 2}
    assert AccessPass.all() == %{"allTest" => true, "allTest2" => 2}
  end

  test "the truth" do
    assert 1 + 1 == 2
  end
end
