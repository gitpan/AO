# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO;

use strict;

$AO::VERSION = '0.32';

1;
__END__

=pod

=head1 NAME

AO - A Perl servlet engine

=head1 SYNOPSIS

For an Apache deployment, add the following to httpd.conf:

  # load Apache 'adapter' and start up engine
  PerlModule Apache::AO

  # tell Apache to delegate handling
  <Location />
    SetHandler perl-script
    PerlHandler Apache::AO
  </Location>

=head1 DESCRIPTION

AO is a servlet engine for Perl. In other words, it provides an
environment in which web components (servlets) written in Perl can be
executed.

While the servlet concept originated with Java, its component model is
quite natural for Perl as well. By writing servlet applications and
deploying them in a servlet engine, application authors can spare
themselves the effort of writing commonly needed web application
infrastructure components for each new project. Furthermore, servlet
applications can be made more portable between deployment
environments; applications written to the Servlet API should be
deployable in any servlet engine using any process model with only a
few configuration changes and no application code changes.

=head2 Servlet API

The Servlet API is the key to writing portable web applications. This
'seam' provides decoupling between the deployment environment
(Apache/mod_perl web server, multiprocess/single thread) and the
application environment (handle request, generate
response). Furthermore, it provides access to the web environment
portably between web servers. Applications written to the Servlet API
are insulated from changes in vendor or platform and are able to
portably take advantage of standard web infrastructure services
offered by any servlet engine.

=head2 Servlet Engine

The servlet engine itself works with a web server to negotiate network
services, HTTP/S protocol handling, and MIME formatting. It also
manages web applications and servlets throughout their
lifecycles. Perhaps most importantly, it provides web infrastructure
services such as security, session management, configuration, and
logging to servlet applications. The servlet engine may also provide
an environment in which web applications can be distributed over
processes and machines.

=head1 FEATURES

AO provides a Perl web application environment with several standard
infrastructure services:

=over

=item Configuration

The servlet engine is configured via an XML file, C<server.xml>. The
main controller of the engine is represented as a I<ContextManager>,
and each web application deployed into the engine is represented as a
I<Context>. Various I<Interceptors> and I<Loggers> can be configured
globally and per-context to provide infrastructure and application
services.

Web applications themselves are configured by their own XML files,
C<web.xml>, as described in the Servlet Specification. Application
attributes, security, servlets, and the mapping of servlets to the
application's URI namespace are described here on a per-application
basis.

See L<AO::Config::Server> and L<AO::Config::Context> for more
information on configuration.

=item Session Management

AO establishes a session for each web client interacting with the
engine and maps each HTTP request to a session. Information of a
transitory nature can be persisted for the life of a session using the
session persistence framework; DBI and filesystem implementations are
provided.

See L<AO::Interceptor::SessionManager>,
L<AO::SessionManager::BaseSessionManager> and
L<AO::Interceptor::Session> for more information on session
management.

=item Security

AO provides security for web applications by implementing both
authentication and authorization checks. The security administrator
can define security policy domains (realms) in which various security
roles are granted access to parts of the URI namespace, and security
technology domains which each use a specific mechanism for
authenticating users and verifying their assignment to a particular
role via the access control framework; a DBI implementation is
provided.

See L<AO::Interceptor::Access> and L<AO::Interceptor::RealmBase> for
more information on security.

=item Logging

AO provides a flexible logging interface based on that of syslog;
given a base log level, the servlet engine will log only events of
that severity or greater. Syslog and Apache implementations are
provided, and others can be created using the logging framework.

See L<AO::Logger::BaseLogger> for more information on logging.

=back

=head2 An Example

A client program, such as a web browser, makes an HTTP request of a
web server. The request is handed off to the servlet engine, which
creates or restores the session corresponding to the client program,
performs security checks if appropriate, determines which servlet to
invoke and calls the servlet, passing objects representing the request
and response. The servlet engine may run within the web server
process, in another process on the same host, or on a different host
altogether.

The servlet extracts data from the request object, performs its
application logic, and sends data back to the engine via the response
object. The engine passes the response data back to the web server and
performs any necessary cleanup operations (persisting session state,
for example). The web server sends an HTTP response to the client to
conclude the transaction.

=head1 INSTALLATION

AO has only been tested under Linux. The AO code itself is all Perl
and thus should work in any environment with a working perl
interpreter. The framework requires a small number of CPAN modules,
and the standard and extended set of interceptors require several
more.

At this time, AO only provides a web server adapter for
Apache/mod_perl. It is anticipated that a FastCGI adapter will be
implemented in the near future.

AO is installed in the standard MakeMaker fashion:

  perl Makefile.PL
  make
  make test
  make install

No scripts or config files are installed, just the AO
libraries. You'll need to place server.xml manually (see below).

=head1 CONFIGURATION

The servlet engine and each web application are configured with XML
files. Furthermore, the web server must be configured to communicate
with the servlet engine as appropriate.

The following points of configuration are common to all AO
deployments:

=over

=item base directory

By default, the AO base directory will be web-server
specific. However, C<$ENV{AO_HOME}> can always be used to specify an
alternate base directory (for example, C</home/bcm/work/ao>).

=item server.xml

AO will search for C<server.xml> inside its base directory, in the
following order: C<./conf/server.xml>, C<./etc/server.xml>,
C<./server.xml>. $ENV{AO_CONFIG} can be used to specify an exact
location (for example, C</home/bcm/work/server.xml>); in this case, AO
will not search through the above subdirectories.

See L<AO::Config::Server> for a complete description of configuring
C<server.xml>. An example can be found at C<etc/server.xml>.

=item web.xml

For each context configured within C<server.xml>, AO will look for
C<web.xml> inside C<E<lt>context doc_baseE<gt>/WEB-INF>.

See L<AO::Config> for a complete description of configuring
C<web.xml>. Examples can be found at C<share/examples/WEB-INF/web.xml>
and C<share/admin/WEB-INF/web.xml>.

=back

=head2 Apache/mod_perl

The following points of configuration are specific to the
Apache/mod_perl environment:

=over

=item base directory

By default, the AO base directory is the Apache server
root. C<$ENV{AO_HOME}> can be used to specify an alternate base
directory as described above.

=item httpd.conf

Apache has to be told to load the C<Apache::AO> adapter module and to
use it as the handler for all relevant Location/Directory/Files
blocks. C<WEB-INF> directories should be protected by denying access
to them.

If environment variables are to be used to influence AO's
configuration, they must be set B<before> C<Apache::AO> is
loaded. Either set them in the shell before starting the web server,
or use a C<BEGIN> block before loading the module.

See C<etc/ao.conf> for an example snippet of Apache configuration
code.

=back

=head1 ARCHITECTURE

The architecture of the AO servlet engine is actually quite
straightforward. On a per-request basis, a controller accepts normalized
requests from a web server adapter, identifies the appropriate servlet
and delegates service to it, and routes the servlet's response back to
the web server adapter. The servlet itself is the gateway to the logic
of the application layer. Furthermore, event handlers are given the
opportunity to react at various points during the service process and
during the lifecycle of the engine and its web applications.

=head2 Adapters

These are the components that communicate between the web server and
the servlet engine. There is no actual adapter class, since each web
server and/or process model may require vastly different strategies
for adapting. If similarities appear as more adapters are developed,
this decision may be revisited.

The responsibilities of an adapter are to instantiate a context
manager; process the engine's configuration; and to drive the context
manager's lifecycle.

See L<Apache::AO> for more information on the Apache adapter.

=head2 Context Manager

The control and sequencing functions of the engine are allocated to
the I<ContextManager>. Its responsibilities are to maintain the list
of web applications (I<Contexts>) deployed into the engine, and add,
reload or remove web applications as necessary; to provide a starting
point for the engine itself; and to shepherd the various internal
objects through the process of servicing an individual request.

See L<AO::ContextManager> for more information.

=head2 Contexts

Each web application is represented internally by a I<Context>. These
objects aren't terribly interesting in their own right; they are
basically bundles of attributes and associations to other objects. It
is using the context that the engine and interceptors can execute
context-specific behavior during lifecycle and requext servicing
(security constraints are a good example), and it is from the context
that servlets get all their knowledge of the servlet environment.

See L<AO::Context> for more information.

=head2 Interceptors

The processes of startup, request servicing and shutdown offer a lot
of room for customization of the engine's behavior. The AO architecture is
built around the notion of I<Interceptors> that modify the behavior of
the core engine. Each Interceptor has the opportunity to respond to
engine lifecycle and/or request handling events.

The standard behavior of the engine is implemented with Interceptors
as well. This allows an additional level of flexibility beyond the
'plug in your own session persistence implementation' level. The
session management framework can be removed or replaced with a
completely custom framework, as desired.

Note: the order in which interceptors are declared in C<server.xml> is
very important. Since there is no way for an interceptor to signal
that no more interceptors should be given the ability to handle a
particular event, a later interceptor can possibly undo or overwrite
an earlier interceptor's work. It's yet to be seen if this is a
liability or a simplification.

See L<AO::BaseInterceptor> for more information.

=head2 Lifecycle Events

A I<ContextInterceptor> acts on events in the lifecycle of the engine
and of each context. Each of the following events is called on each
context interceptor:

=over

=item engine_init

Called when the context manager is initialized by the
adapter. Typically where global resources are initialized, such as
database connections, etc.

=item context_init

Called after the instantiation of a context, in order to prepare it
for service. Typically where the context configuration is processed,
servlets are preloaded, etc.

=item add_context

Called when a context is added to the context manager's list.

=item remove_context

Called when a context is removed from the context manager's list.

=item context_shutdown

Called when a context is removed from service. Typically used to
release resources used by that context only; for instance, to remove
all active sessions for the context.

=item engine_shutdown

Called when the context manager is about to end service. Typically
used to release global resources, such as database connections.

=back

See L<AO::Interceptor::ContextInterceptor> for more information about
interceptors that act on lifecycle events.

=head2 Service Events

A I<RequestInterceptor> acts on events during the servicing of each
request. Each of the following events is called on each reequest
interceptor:

=over

=item context_map

Called to determine to which context the request was directed.

=item request_map

Called to determine which servlet will service the request. Also used
by the standard security mechanism to determine if the request must be
authenticated.

=item authenticate

Called to check the validity of submitted credentials.

=item authorize

Called to check if the previously authenticated user is in the
security role specified by the context's security configuration.

=item pre_service

Called just before the servlet takes control of the request.

=item post_service

Called just after the servlet has serviced the request.

=back

See L<AO::Interceptor::RequestInterceptor> for more information about
interceptors that act on service events.

=head2 Service

This is the actual point at which the servlet engine relinquishes
control and the servlet takes over; in other words, it is the entry
point for the servlet application.

See L<AO::Servlet::BaseServlet> for more information about servlets.

=head1 AUTHOR

Brian Moseley, bcm@maz.org

=cut


