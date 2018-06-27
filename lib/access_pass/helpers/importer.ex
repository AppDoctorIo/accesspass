defmodule AccessPass.Importer do
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

  def apl({mod, func, arg}) do
    apply(mod, func, arg)
  end

  defp router(func, arg) do
    if Application.get_env(:access_pass, :distributed) == true do
      apl({AccessPass.EtsDistributed, func, arg})
    else
      apl({AccessPass.Ets, func, arg})
    end
  end
end
