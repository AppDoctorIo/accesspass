defmodule AccessPass.Importer do
  @moduledoc false
  def insert(name, obj) do
    router(:insert, [name, obj])
  end

  def insert_with_revoke(name, obj, tup) do
    router(:insert_with_revoke, [name, obj, tup])
  end

  def delete(name, key) do
    router(:delete, [name, key])
  end

  def match_object(name, object) do
    router(:match_object, [name, object])
  end

  def match_delete(name, obj) do
    router(:match_delete, [name, obj])
  end

  def match(name, obj) do
    router(:match, [name, obj])
  end

  def new(name, opts) do
    router(:new, [name, opts])
  end

  defp router(func, arg) do
    if Application.get_env(:access_pass, :distributed) == true do
      apply(AccessPass.EtsDistributed, func, arg)
    else
      apply(AccessPass.Ets, func, arg)
    end
  end
end
