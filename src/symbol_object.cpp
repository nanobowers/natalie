#include "natalie.hpp"

namespace Natalie {

SymbolObject *SymbolObject::intern(const char *name, size_t length) {
    assert(name);
    return intern(String(name, length));
}

SymbolObject *SymbolObject::intern(const String &name) {
    SymbolObject *symbol = s_symbols.get(name);
    if (symbol)
        return symbol;
    symbol = new SymbolObject { name };
    s_symbols.put(name, symbol);
    return symbol;
}

ArrayObject *SymbolObject::all_symbols(Env *env) {
    ArrayObject *array = new ArrayObject(s_symbols.size());
    for (auto pair : s_symbols) {
        array->push(pair.second);
    }
    return array;
}

StringObject *SymbolObject::inspect(Env *env) {
    StringObject *string = new StringObject { ":" };
    // FIXME: surely we can do this without a regex
    auto quote_regex = RegexpObject { env, "\\A\\$(\\d|\\?|\\!|~)\\z|\\A(@{0,2}|\\$)[a-z_][a-z0-9_]*[\\?\\!=]?\\z|\\A(%|==|\\!|\\!=|\\+|\\-|/|\\*{1,2}|<<?|>>?|\\[\\]\\=?|&)\\z", 1 };
    bool quote = quote_regex.match(env, new StringObject { m_name })->is_falsey();
    for (size_t i = 0; i < m_name.length(); ++i) {
        auto c = m_name[i];
        if (c < 33 || c > 126) // FIXME: probably can be a smaller range
            quote = true;
    }
    if (m_name.length() > 1 && m_name[0] == '$')
        quote = false;
    if (quote) {
        StringObject *quoted = StringObject { m_name }.inspect(env);
        string->append(quoted);
    } else {
        string->append(m_name);
    }
    return string;
}

String SymbolObject::dbg_inspect() const {
    return String::format(":{}", m_name);
}

Value SymbolObject::eqtilde(Env *env, Value other) {
    other->assert_type(env, Object::Type::Regexp, "Regexp");
    return other->as_regexp()->eqtilde(env, this);
}

SymbolObject *SymbolObject::succ(Env *env) {
    auto string = to_s(env);
    string = string->send(env, "succ"_s)->as_string();
    return string->to_symbol(env);
}

SymbolObject *SymbolObject::upcase(Env *env) {
    auto string = to_s(env);
    string = string->send(env, "upcase"_s)->as_string();
    return string->to_symbol(env);
}

SymbolObject *SymbolObject::downcase(Env *env) {
    auto string = to_s(env);
    string = string->send(env, "downcase"_s)->as_string();
    return string->to_symbol(env);
}

SymbolObject *SymbolObject::swapcase(Env *env) {
    auto string = to_s(env);
    string = string->send(env, "swapcase"_s)->as_string();
    return string->to_symbol(env);
}

SymbolObject *SymbolObject::capitalize(Env *env) {
    auto string = to_s(env);
    string = string->send(env, "capitalize"_s)->as_string();
    return string->to_symbol(env);
}
Value SymbolObject::casecmp(Env *env, Value other) {
    if (!other->is_symbol()) return NilObject::the();
    auto str1 = to_s(env);
    auto str2 = other->to_s(env);
    str1 = str1->send(env, "downcase"_s, { "ascii"_s })->as_string();
    str2 = str2->send(env, "downcase"_s, { "ascii"_s })->as_string();
    return str1->cmp(env, Value(str2));
}

Value SymbolObject::is_casecmp(Env *env, Value other) {
    if (!other->is_symbol()) return NilObject::the();
    // other->assert_type(env, Object::Type::Symbol, "Symbol");
    auto str1 = to_s(env);
    auto str2 = other->to_s(env);
    str1 = str1->send(env, "downcase"_s, { "ascii"_s })->as_string();
    str2 = str2->send(env, "downcase"_s, { "ascii"_s })->as_string();
    if (str1->string() == str2->string())
        return TrueObject::the();
    return FalseObject::the();
}

ProcObject *SymbolObject::to_proc(Env *env) {
    auto block_env = new Env {};
    block_env->var_set("name", 0, true, this);
    Block *proc_block = new Block { block_env, this, SymbolObject::to_proc_block_fn, -2 };
    return new ProcObject { proc_block };
}

Value SymbolObject::to_proc_block_fn(Env *env, Value self_value, Args args, Block *block) {
    args.ensure_argc_at_least(env, 1);
    SymbolObject *name_obj = env->outer()->var_get("name", 0)->as_symbol();
    assert(name_obj);
    auto method_args = Args::shift(args);
    return args[0].send(env, name_obj, method_args);
}

Value SymbolObject::cmp(Env *env, Value other_value) {
    if (!other_value->is_symbol()) return NilObject::the();
    SymbolObject *other = other_value->as_symbol();
    return Value::integer(m_name.cmp(other->m_name));
}

bool SymbolObject::start_with(Env *env, Args args) {
    return to_s(env)->start_with(env, args);
}

bool SymbolObject::end_with(Env *env, Args args) {
    return to_s(env)->end_with(env, args);
}

Value SymbolObject::length(Env *env) {
    return to_s(env)->size(env);
}

Value SymbolObject::name(Env *env) const {
    SymbolObject *symbol = intern(m_name);
    if (!symbol->m_string) {
        symbol->m_string = symbol->to_s(env);
        symbol->m_string->freeze();
    }
    return symbol->m_string;
}
Value SymbolObject::ref(Env *env, Value index_obj, Value length_obj) {
    // The next line worked in nearly every case, except it did not set `$~`
    // return to_s(env)->send(env, intern("[]"), { index_obj, length_obj });
    return to_s(env)->ref(env, index_obj, length_obj);
}

}
