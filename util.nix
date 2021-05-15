{
  baseDomain = domain: (builtins.head (builtins.elemAt (builtins.split ''([^.]*\.[^.]*$)'' domain) 1));
}
