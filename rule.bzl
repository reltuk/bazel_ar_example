def _rearchive_lib_impl(ctx):
  f = ctx.actions.declare_file(ctx.label.name + ".a")
  inputs = []
  # TODO: Better error handling; if all "objects" aren't found, we should
  # fail(). If there are conflicting sources for an "object", we should fail().
  for d in ctx.attr.deps:
    for linker_input in d[CcInfo].linking_context.linker_inputs.to_list():
      for library in linker_input.libraries:
        for o in library.objects:
          for wanted in ctx.attr.objects:
            if o.path.endswith(wanted):
              inputs.append(o)
  ctx.actions.run(
    outputs = [f],
    inputs = inputs,
    executable = "ar",
    arguments = [
      "r",
      f.path,
    ] + [ f.path for f in inputs ],
  )
  # TODO: Return CcInfo or some other provider to make this consumable to cc_
  # rules upstream.
  return [DefaultInfo(files = depset([f]))]

rearchive_lib = rule(
  implementation = _rearchive_lib_impl,
  attrs = {
    "deps": attr.label_list(providers = [[CcInfo]]),
    "objects": attr.string_list(),
  },
)
