#include "natalie.hpp"

namespace Natalie {

Value Args::operator[](size_t index) const {
    // TODO: remove the assertion here once we're
    // in a good place with the transition to Args
    assert(index < m_size);
    return m_data[index];
}

Value Args::at(size_t index) const {
    assert(index < m_size);
    return m_data[index];
}

Value Args::at(size_t index, Value default_value) const {
    if (index >= m_size)
        return default_value;
    return m_data[index];
}

Args::Args(ArrayObject *array, bool has_keyword_hash)
    : m_size { array->size() }
    , m_data { array->data() }
    , m_has_keyword_hash { has_keyword_hash }
    , m_array { array } { }

Args::Args(const Args &other)
    : m_size { other.m_size }
    , m_data { other.m_data }
    , m_has_keyword_hash { other.m_has_keyword_hash }
    , m_array { other.m_array } { }

Args &Args::operator=(const Args &other) {
    m_size = other.m_size;
    m_data = other.m_data;
    m_has_keyword_hash = other.m_has_keyword_hash;
    m_array = other.m_array;
    return *this;
}

Args Args::shift(Args &args) {
    assert(args.size() > 0);
    if (args.size() == 1)
        return Args();
    auto ary = new ArrayObject(args.size() - 1, args.data() + 1);
    return Args(ary, args.has_keyword_hash());
}

ArrayObject *Args::to_array() const {
    return new ArrayObject { m_size, m_data };
}

ArrayObject *Args::to_array_for_block(Env *env, ssize_t min_count, ssize_t max_count, bool spread) const {
    if (m_size == 1 && spread) {
        auto ary = to_ary(env, m_data[0], true)->dup(env)->as_array();
        ssize_t count = ary->size();
        if (max_count != -1 && count > max_count)
            ary->truncate(max_count);
        else if (count < min_count)
            ary->fill(env, NilObject::the(), Value::integer(ary->size()), Value::integer(min_count - ary->size()), nullptr);
        return ary;
    }
    auto len = max_count >= 0 ? std::min(m_size, (size_t)max_count) : m_size;
    auto ary = new ArrayObject { len, m_data };
    ssize_t count = ary->size();
    if (count < min_count)
        ary->fill(env, NilObject::the(), Value::integer(ary->size()), Value::integer(min_count - ary->size()), nullptr);
    return ary;
}

void Args::ensure_argc_is(Env *env, size_t expected) const {
    if (m_size != expected)
        env->raise("ArgumentError", "wrong number of arguments (given {}, expected {})", m_size, expected);
}

void Args::ensure_argc_between(Env *env, size_t expected_low, size_t expected_high) const {
    if (m_size < expected_low || m_size > expected_high)
        env->raise("ArgumentError", "wrong number of arguments (given {}, expected {}..{})", m_size, expected_low, expected_high);
}

void Args::ensure_argc_at_least(Env *env, size_t expected) const {
    if (m_size < expected)
        env->raise("ArgumentError", "wrong number of arguments (given {}, expected {}+)", m_size, expected);
}

Value Args::keyword_arg(Env *env, SymbolObject *name) const {
    if (!m_has_keyword_hash || m_size == 0)
        return NilObject::the();
    auto hash = m_data[m_size - 1].object_or_null();
    if (!hash || !hash->is_hash())
        return NilObject::the();
    return hash->as_hash()->get(env, name);
}
}
