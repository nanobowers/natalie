#include "natalie.hpp"
#include <grp.h>
#include <unistd.h>

using namespace Natalie;

Value group_to_struct(Env *env, Value self, struct group *grp) {
    auto etc_group = self->const_get("Group"_s);
    assert(etc_group);
    auto grpstruct = etc_group->send(env, "new"_s, {});
    // It is possible more fields could be set, but these
    // are the ones required by POSIX
    grpstruct->send(env, "name="_s, { new StringObject { grp->gr_name } });
    grpstruct->send(env, "passwd="_s, { new StringObject { grp->gr_passwd } });
    grpstruct->send(env, "gid="_s, { new IntegerObject { grp->gr_gid } });
    auto mem_ary = new ArrayObject {};
    char **memptr = grp->gr_mem;
    for (char *member_name = *memptr; member_name; member_name = *++memptr) {
        auto memstr = new StringObject { member_name };
        mem_ary->push(Value(memstr));
    }
    grpstruct->send(env, "mem="_s, { mem_ary });
    return grpstruct;
}

Value passwd_to_struct(Env *env, Value self, struct passwd *pwd) {
    auto etc_passwd = self->const_get("Passwd"_s);
    assert(etc_passwd);
    auto pwdstruct = etc_passwd->send(env, "new"_s, {});
    // It is possible more fields could be set, but these
    // are the ones required by POSIX
    pwdstruct->send(env, "name="_s, { new StringObject { pwd->pw_name } });
    pwdstruct->send(env, "uid="_s, { new IntegerObject { pwd->pw_uid } });
    pwdstruct->send(env, "gid="_s, { new IntegerObject { pwd->pw_gid } });
    pwdstruct->send(env, "dir="_s, { new StringObject { pwd->pw_dir } });
    pwdstruct->send(env, "gecos="_s, { new StringObject { pwd->pw_gecos } });
    pwdstruct->send(env, "passwd="_s, { new StringObject { pwd->pw_passwd } });
    pwdstruct->send(env, "shell="_s, { new StringObject { pwd->pw_shell } });
    return pwdstruct;
}

Value init(Env *env, Value self) {
    ModuleObject *Etc = new ModuleObject { "Etc" };
    GlobalEnv::the()->Object()->const_set("Etc"_s, Etc);
    Etc->const_set("VERSION"_s, new StringObject { "1.3.0" });
    Etc->const_set("CS_PATH"_s, new StringObject { _CS_PATH });
    // POSIX.1 variables [sysconf(3) man page]
    Etc->const_set("SC_ARG_MAX"_s, new IntegerObject { _SC_ARG_MAX });
    Etc->const_set("SC_CHILD_MAX"_s, new IntegerObject { _SC_CHILD_MAX });
    Etc->const_set("SC_HOST_NAME_MAX"_s, new IntegerObject { _SC_HOST_NAME_MAX });
    Etc->const_set("SC_LOGIN_NAME_MAX"_s, new IntegerObject { _SC_LOGIN_NAME_MAX });
    Etc->const_set("SC_NGROUPS_MAX"_s, new IntegerObject { _SC_NGROUPS_MAX });
    Etc->const_set("SC_CLK_TCK"_s, new IntegerObject { _SC_CLK_TCK });
    Etc->const_set("SC_OPEN_MAX"_s, new IntegerObject { _SC_OPEN_MAX });
    Etc->const_set("SC_PAGESIZE"_s, new IntegerObject { _SC_PAGESIZE });
    Etc->const_set("SC_PAGE_SIZE"_s, new IntegerObject { _SC_PAGE_SIZE });
    Etc->const_set("SC_RE_DUP_MAX"_s, new IntegerObject { _SC_RE_DUP_MAX });
    Etc->const_set("SC_STREAM_MAX"_s, new IntegerObject { _SC_STREAM_MAX });
    Etc->const_set("SC_SYMLOOP_MAX"_s, new IntegerObject { _SC_SYMLOOP_MAX });
    Etc->const_set("SC_TTY_NAME_MAX"_s, new IntegerObject { _SC_TTY_NAME_MAX });
    Etc->const_set("SC_TZNAME_MAX"_s, new IntegerObject { _SC_TZNAME_MAX });
    Etc->const_set("SC_VERSION"_s, new IntegerObject { _SC_VERSION });

    return NilObject::the();
}

Value Etc_endgrent(Env *env, Value self, Args args, Block *_block) {
    args.ensure_argc_is(env, 0);
    ::endgrent();
    return NilObject::the();
}
Value Etc_endpwent(Env *env, Value self, Args args, Block *_block) {
    args.ensure_argc_is(env, 0);
    ::endpwent();
    return NilObject::the();
}

Value Etc_getgrent(Env *env, Value self, Args args, Block *_block) {
    args.ensure_argc_is(env, 0);
    struct group *grp = ::getgrent();
    if (!grp) return NilObject::the();
    return group_to_struct(env, self, grp);
}

Value Etc_getgrgid(Env *env, Value self, Args args, Block *_block) {
    args.ensure_argc_between(env, 0, 1);
    uid_t uid;
    if (args.size() == 1) {
        uid = IntegerObject::convert_to_nat_int_t(env, args.at(0));
    } else {
        uid = ::getgid();
    }
    struct group *grp = ::getgrgid(uid);
    if (!grp) env->raise_errno();
    return group_to_struct(env, self, grp);
}

Value Etc_getgrnam(Env *env, Value self, Args args, Block *_block) {
    args.ensure_argc_is(env, 1);
    auto firstarg = args.at(0);
    firstarg->assert_type(env, Object::Type::String, "String");
    StringObject *groupname = firstarg->as_string();
    struct group *grp = ::getgrnam(groupname->c_str());
    if (!grp)
        env->raise("ArgumentError", "can't find group for {}", groupname->string());
    return group_to_struct(env, self, grp);
}

//
Value Etc_getlogin(Env *env, Value self, Args args, Block *_block) {
    args.ensure_argc_is(env, 0);
    char *login = ::getlogin();
    if (!login) login = ::getenv("USER");
    if (!login) return NilObject::the();
    return new StringObject { login, EncodingObject::locale() };
}

Value Etc_getpwent(Env *env, Value self, Args args, Block *_block) {
    args.ensure_argc_is(env, 0);
    struct passwd *pwd = ::getpwent();
    if (!pwd) return NilObject::the();
    return passwd_to_struct(env, self, pwd);
}

Value Etc_getpwnam(Env *env, Value self, Args args, Block *_block) {
    args.ensure_argc_is(env, 1);
    auto firstarg = args.at(0);
    firstarg->assert_type(env, Object::Type::String, "String");
    StringObject *user_name = firstarg->as_string();
    struct passwd *pwd = ::getpwnam(user_name->c_str());
    if (!pwd)
        env->raise("ArgumentError", "can't find user for {}", user_name->string());
    return passwd_to_struct(env, self, pwd);
}

Value Etc_getpwuid(Env *env, Value self, Args args, Block *_block) {
    args.ensure_argc_between(env, 0, 1);
    uid_t uid;
    if (args.size() == 1) {
        uid = IntegerObject::convert_to_nat_int_t(env, args.at(0));
    } else {
        uid = ::getuid();
    }
    struct passwd *pwd = ::getpwuid(uid);
    if (!pwd) env->raise_errno();
    return passwd_to_struct(env, self, pwd);
}

Value Etc_setgrent(Env *env, Value self, Args args, Block *_block) {
    args.ensure_argc_is(env, 0);
    ::setgrent();
    return NilObject::the();
}

Value Etc_setpwent(Env *env, Value self, Args args, Block *_block) {
    args.ensure_argc_is(env, 0);
    ::setpwent();
    return NilObject::the();
}

Value Etc_sysconf(Env *env, Value self, Args args, Block *_block) {
    args.ensure_argc_is(env, 1);
    nat_int_t nameval = IntegerObject::convert_to_nat_int_t(env, args.at(0));
    errno = 0;
    long status = ::sysconf(nameval);
    if (status < 0) {
        if (errno) env->raise_errno();
        return NilObject::the();
    }
    return new IntegerObject { status };
}
