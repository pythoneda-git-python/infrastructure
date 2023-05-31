from PythonEDA.event import Event
from PythonEDAInfrastructure.network.grpc.server import GrpcServer
from PythonEDAGitRepositories.git_repo_requested import GitRepoRequested
import logging

class GitRepositoriesGrpcServer(GrpcServer):

    async def GitRepoRequestedNotifications(self, request, context):
        logging.getLogger(__name__).debug(f'Received "{request}", "{context}"')
#        response = git_repo_requested_pb2.Reply(code=200)
        event = self.build_git_repo_requested(request)
        await self.app.accept(event)
        return response

    async def add_servicers(self, server, app):
        # TODO: git_repo_requested_pb2_grpc.add_GitRepoRequestedServiceServicer_to_server(self, server)
        pass
#
    def build_git_repo_requested(self, request) -> Event:
        return GitRepoRequested(request.package_name, request.package_version)
