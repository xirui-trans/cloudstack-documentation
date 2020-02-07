.. Licensed to the Apache Software Foundation (ASF) under one
   or more contributor license agreements.  See the NOTICE file
   distributed with this work for additional information#
   regarding copyright ownership.  The ASF licenses this file
   to you under the Apache License, Version 2.0 (the
   "License"); you may not use this file except in compliance
   with the License.  You may obtain a copy of the License at
   http://www.apache.org/licenses/LICENSE-2.0
   Unless required by applicable law or agreed to in writing,
   software distributed under the License is distributed on an
   "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
   KIND, either express or implied.  See the License for the
   specific language governing permissions and limitations
   under the License.
 

角色, 账户, 用户, 域
-----------------------------------

角色
~~~~~

角色代表了一组操作的集合。
所有的CloudStack账户都必须绑定一个角色，以便管理他们的访问权限和限制API请求。
有几个默认的角色：root 管理员，资源管理员，域管理员和普通用户。


账户
~~~~~~~~

账户代表服务提供商的客户或者一个大型组织机构中的部门。
一个账户下可以有多个用户。


域
~~~~~~~

账户按域进行分组。
域通常包含多个账户，这些账户之间有一定的逻辑关系，并且共用一组有特殊权限的管理员来对该域及其子域进行管理。
例如，具有多个分销商的服务提供商，可以为每个经销商创建一个域。

每个账户创建的时候，CloudStack会创建3个默认的用户账户：
root 管理员，域管理员和普通用户。


用户
~~~~~

用户比较类似于账户的别名。
同一个账户下的用户之间不进行隔离，不同账户下的用户是隔离的。
大多数安装不需要关注用户这个概念，他们每个账户下只有一个用户。
同一个用户不能从属于多个账户。

用户名再域中的账户下是唯一的。
不同域或子域下可以有相同的用户名。
域名的完整路径不能重复。
例如：可以创建root/d1, root/foo/d1, root/sales/d1。

管理员是具有特殊权限的账户。
系统中可能有多个系统管理员。
管理员可以创建或者删除其它管理员，可以修改任意用户的密码。


域管理员
~~~~~~~~~~~~~~~~~~~~~

域管理员可以管理该域下的用户。
域管理员不能查看物理服务器和其他域。


Root 管理员
~~~~~~~~~~~~~~~~~~

Root 管理员拥有系统的完整访问权限，包括管理模板、计算服务、customer care administrators、域等。


资源归属
~~~~~~~~~~~~~~~~~~

资源属于账户而不是账户下的用户。
例如: 账单，资源限制等等是基于账户而不是用户来维护的。
用户可以操作其账户下的任何资源(账户对这些资源有操作权限，这些权限取决于账户绑定的角色)。
Root 账户可以通过assignVirtualMachine API 来修改任一虚拟机的归属，
将其分配给其他的账户。
域或子域的管理员也可以做类似的操作，在域或子域内，将虚拟机分配给域内的其他账户。

.. _using-dynamics-roles:

动态角色
-------------------

In addition to the four default roles, the dynamic role-based API checker feature
allows CloudStack root admins to create new roles with customized permissions.
The allow/deny rules can be configured dynamically during runtime without
restarting the management server(s).

For backward compatiblity, all roles resolve to one of the four role types:
admin, resource admin, domain admin and user. A new role can be created using
the roles tab in the UI and specifying a name, a role type and optionally a
description.

Role specific rules can be configured through the rules tab on role specific
details page. A rule is either an API name or a wildcard string that are one of
allow or deny permission and optionally a description.

When a user makes an API request, the backend checks the requested API against
configured rules (in the order the rules were configured) for the caller
user-account's role. It will iterate through the rules and would allow the
API request if the API matches an allow rule, else if it matches a deny rule
it would deny the request. Next, if the request API fails to match any of
the configured rules it would allow if the requested API's default authorized
annotaions allow that user role type and finally deny the user API request
if it fails to be explicitly allowed/denied by the role permission rules or the
default API authorize annotations. Note: to avoid root admin being locked
out of the system, all root admin accounts are allowed all APIs.

The dynamic-roles feature is enabled by default only for all new CloudStack
installations since version `4.9.x <https://cwiki.apache.org/confluence/display/CLOUDSTACK/Dynamic+Role+Based+API+Access+Checker+for+CloudStack>`_.

After an upgrade, existing deployments can be migrated to use this feature by
running a migration tool by the CloudStack admin. The migration tool is located
at ``/usr/share/cloudstack-common/scripts/util/migrate-dynamicroles.py``.

**NOTE: If you have not changed your commands.properties file at any time, then 
it is recommended to use the -D (default) option as otherwise new API commands may 
not be added to the dynamic roles database.**

During migration, this tool enables an internal flag in the database,
copies existing static role-based rules from provided commands.properties file
(typically at ``/etc/cloudstack/management/commands.properties``) to the database
and renames the commands.properties file (typically to
/etc/cloudstack/management/commands.properties.deprecated). The migration
process does not require restarting the management server(s).

Usage: ``migrate-dynamicroles.py`` [options] [-h for help]

Options:

-b DB
    The name of the database, default: cloud
-u USER
    User name a MySQL user with privileges on cloud database, default: cloud
-p PASSWORD
    Password of a MySQL user with privileges on cloud database
-H HOST
    Host or IP of the MySQL server
-P PORT
    Host or IP of the MySQL server, default: 3306
-f FILE
    The commands.properties file, default: /etc/cloudstack/management/commands.properties
-d
    Dry run and debug operations this tool will perform
-D
    Use the default configuration for Dynamic Roles (does not import commands.properties)


Example:
 

.. parsed-literal::

   sudo python /usr/share/cloudstack-common/scripts/util/migrate-dynamicroles.py -u cloud -p cloud -H localhost -P 3306 -f /etc/cloudstack/management/commands.properties

   sudo python /usr/share/cloudstack-common/scripts/util/migrate-dynamicroles.py -u cloud -p cloud -H localhost -P 3306 -D

If you've multiple management servers, remove or rename the commands.properties
file on all management servers typically in /etc/cloudstack/management path,
after running the migration tool for the first management server


给账户和域分配资源
--------------------------------------------

The root administrator can dedicate resources to a specific domain or
account that needs private infrastructure for additional security or
performance guarantees. A zone, pod, cluster, or host can be reserved by
the root administrator for a specific domain or account. Only users in
that domain or its subdomain may use the infrastructure. For example,
only users in a given domain can create guests in a zone dedicated to
that domain.

There are several types of dedication available:

-  Explicit dedication. A zone, pod, cluster, or host is dedicated to an
   account or domain by the root administrator during initial deployment
   and configuration.

-  Strict implicit dedication. A host will not be shared across multiple
   accounts. For example, strict implicit dedication is useful for
   deployment of certain types of applications, such as desktops, where
   no host can be shared between different accounts without violating
   the desktop software's terms of license.

-  Preferred implicit dedication. The VM will be deployed in dedicated
   infrastructure if possible. Otherwise, the VM can be deployed in
   shared infrastructure.

将资源域、集群、机架和主机分配给账户或域
----------------------------------------------------------------------

For explicit dedication: When deploying a new zone, pod, cluster, or
host, the root administrator can click the Dedicated checkbox, then
choose a domain or account to own the resource.

To explicitly dedicate an existing zone, pod, cluster, or host: log in
as the root admin, find the resource in the UI, and click the Dedicate
button. |button to dedicate a zone, pod,cluster, or host|

For implicit dedication: The administrator creates a compute service
offering and in the Deployment Planner field, chooses
ImplicitDedicationPlanner. Then in Planner Mode, the administrator
specifies either Strict or Preferred, depending on whether it is
permissible to allow some use of shared resources when dedicated
resources are not available. Whenever a user creates a VM based on this
service offering, it is allocated on one of the dedicated hosts.


How to Use Dedicated Hosts
~~~~~~~~~~~~~~~~~~~~~~~~~~~

To use an explicitly dedicated host, use the explicit-dedicated type of
affinity group (see `“Affinity Groups” <virtual_machines.html#affinity-groups>`_). 
For example, when creating a new VM, an
end user can choose to place it on dedicated infrastructure. This
operation will succeed only if some infrastructure has already been
assigned as dedicated to the user's account or domain.


Behavior of Dedicated Hosts, Clusters, Pods, and Zones
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The administrator can live migrate VMs away from dedicated hosts if
desired, whether the destination is a host reserved for a different
account/domain or a host that is shared (not dedicated to any particular
account or domain). CloudStack will generate an alert, but the operation
is allowed.

Dedicated hosts can be used in conjunction with host tags. If both a
host tag and dedication are requested, the VM will be placed only on a
host that meets both requirements. If there is no dedicated resource
available to that user that also has the host tag requested by the user,
then the VM will not deploy.

If you delete an account or domain, any hosts, clusters, pods, and zones
that were dedicated to it are freed up. They will now be available to be
shared by any account or domain, or the administrator may choose to
re-dedicate them to a different account or domain.

System VMs and virtual routers affect the behavior of host dedication.
System VMs and virtual routers are owned by the CloudStack system
account, and they can be deployed on any host. They do not adhere to
explicit dedication. The presence of system vms and virtual routers on a
host makes it unsuitable for strict implicit dedication. The host can
not be used for strict implicit dedication, because the host already has
VMs of a specific account (the default system account). However, a host
with system VMs or virtual routers can be used for preferred implicit
dedication.


Using an LDAP Server for User Authentication
--------------------------------------------

You can use an external LDAP server such as Microsoft Active Directory
or ApacheDS to authenticate CloudStack end-users. CloudStack will search
the external LDAP directory tree starting at a specified base directory
and gets user info such as first name, last name, email and username.

To authenticate, username and password entered by the user are used.
Cloudstack does a search for a user with the given username. If it
exists, it does a bind request with DN and password.

To set up LDAP authentication in CloudStack, call the CloudStack API
command ``addLdapConfiguration`` and provide Hostname or IP address
and listening port of the LDAP server. You could configure multiple
servers as well. These are expected to be replicas. If one fails,
the next one is used.

The following global configurations should also be configured (the
default values are for openldap)

-  ``ldap.basedn``:	Sets the basedn for LDAP. Ex: **OU=APAC,DC=company,DC=com**

-  ``ldap.bind.principal``, ``ldap.bind.password``: DN and password for a user
   who can list all the users in the above basedn. Ex:
   **CN=Administrator, OU=APAC, DC=company, DC=com**

-  ``ldap.user.object``: object type of users within LDAP. Defaults value is
   **user** for AD and **interorgperson** for openldap.

-  ``ldap.email.attribute``: email attribute within ldap for a user. Default
   value for AD and openldap is **mail**.

-  ``ldap.firstname.attribute``: firstname attribute within ldap for a user.
   Default value for AD and openldap is **givenname**.

-  ``ldap.lastname.attribute``: lastname attribute within ldap for a user.
   Default value for AD and openldap is **sn**.

-  ``ldap.username.attribute``: username attribute for a user within LDAP.
   Default value is **SAMAccountName** for AD and **uid** for openldap.


Restricting LDAP users to a group:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  ``ldap.search.group.principle``: this is optional and if set only users from
   this group are listed.


LDAP SSL:
~~~~~~~~~

If the LDAP server requires SSL, you need to enable the below configurations.
Before enabling SSL for LDAP, you need to get the certificate which the LDAP server is using and add it to a trusted keystore.
You will need to know the path to the keystore and the password.

-  ``ldap.truststore`` : truststore path
-  ``ldap.truststore.password`` : truststore password


LDAP 组:
~~~~~~~~~~~~

-  ``ldap.group.object``: object type of groups within LDAP. Default value is
   group for AD and **groupOfUniqueNames** for openldap.	

-  ``ldap.group.user.uniquemember``: attribute for uniquemembers within a group.
   Default value is **member** for AD and **uniquemember** for openldap.

Once configured, on Add Account page, you will see an "Add LDAP Account" button
which opens a dialog and the selected users can be imported.

.. figure:: /_static/images/CloudStack-ldap-screen1.png
   :align:   center


You could also use api commands: ``listLdapUsers``, ``ldapCreateAccount`` and
``importLdapUsers``.

Once LDAP is enabled, the users will not be allowed to changed password
directly in cloudstack.



.. |button to dedicate a zone, pod,cluster, or host| image:: /_static/images/dedicate-resource-button.png

使用SAML 2.0 Identity Provider 做用户认证
----------------------------------------------------------

You can use a SAML 2.0 Identity Provider with CloudStack for user
authentication. This will require enabling the SAML 2.0 service provider plugin
in CloudStack. To do that first, enable the SAML plugin by setting
``saml2.enabled`` to ``true`` and restart management server.

Starting 4.5.2, the SAML plugin uses an authorization workflow where users should
be authorized by an admin using ``authorizeSamlSso`` API before those users can
use Single Sign On against a specific IDP. This can be done by ticking the enable
SAML Single Sign On checkbox and selecting a IDP when adding or importing users.
For existing users, admin can go to the user's page and click on configure
SAML SSO option to enable/disable SSO for a user and select a Identity Provider.
A user can be authorized to authenticate against only one IDP.

The CloudStack service provider metadata is accessible using the
``getSPMetadata`` API command, or from the URL
http://acs-server:8080/client/api?command=getSPMetadata where acs-server is the
domain name or IP address of the management server. The IDP administrator can
get the SP metadata from CloudStack and add it to their IDP server.

To start a SAML 2.0 Single Sign-On authentication, on the login page users need to
select the Identity Provider or Institution/Department they can authenticate with
and click on Login button. This action call the ``samlsso`` API command which
will redirect the user to the Identity Provider's login page. Upon successful
authentication, the IdP will redirect the user to CloudStack. In case a user has
multiple user accounts with the same username (across domains) for the same
authorized IDP, that user would need to specify domainpath after selecting their
IDP server from the dropdown list. By default, users don't need to specify any
domain path. After a user is successfully authenticated by an IDP server, the SAML
authentication plugin finds user accounts whose username match the username
attribute value returned by the SAML authentication response; it fails
only when it finds that there are multiple user accounts with the same user name
for the specific IDP otherwise the unique useraccount is allowed to proceed and
the user is logged into their account.

Limitations:

- The plugin uses a user attribute returned by the IDP server in the SAML response
  to find and map the authorized user in CloudStack. The default attribute is `uid`.

- The SAML authentication plugin supports HTTP-Redirect and HTTP-Post bindings.

- Tested with Shibboleth 2.4, SSOCircle, Microsoft ADFS, OneLogin, Feide OpenIDP,
  PingIdentity.

The following global configuration should be configured:

- ``saml2.enabled``: Indicates whether SAML SSO plugin is enabled or not true. Default is **false**

- ``saml2.sp.id``: SAML2 Service Provider Identifier string

- ``saml2.idp.metadata.url``: SAML2 Identity Provider Metadata XML Url or Filename. If a URL is not provided, it will look for a file in the config directory /etc/cloudstack/management

- ``saml2.default.idpid``: The default IdP entity ID to use only in case of multiple IdPs

- ``saml2.sigalg``: The algorithm to use to when signing a SAML request. Default is SHA1, allowed algorithms: SHA1, SHA256, SHA384, SHA512.

- ``saml2.redirect.url``: The CloudStack UI url the SSO should redirected to when successful. Default is **http://localhost:8080/client**

- ``saml2.sp.org.name``: SAML2 Service Provider Organization Name

- ``saml2.sp.org.url``: SAML2 Service Provider Organization URL

- ``saml2.sp.contact.email``: SAML2 Service Provider Contact Email Address

- ``saml2.sp.contact.person``: SAML2 Service Provider Contact Person Name

- ``saml2.sp.slo.url``: SAML2 CloudStack Service Provider Single Log Out URL

- ``saml2.sp.sso.url``: SAML2 CloudStack Service Provider Single Sign On URL

- ``saml2.user.attribute``: Attribute name to be looked for in SAML response that will contain the username. Default is **uid**

- ``saml2.timeout``: SAML2 IDP Metadata refresh interval in seconds, minimum value is set to 300. Default is 1800

