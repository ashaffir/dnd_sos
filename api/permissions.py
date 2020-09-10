from rest_framework.permissions import BasePermission

class IsOwnerOrReadOnly(BasePermission):
    message = 'You must be the owner of this order to modify it.'
    my_safe_method = ['PUT']
    def has_object_permission(self, request, view, obj):
        if request.method in self.my_safe_method:
            return True
        
        return obj.user == request.user

class IsOwner(BasePermission):
    """
    Custom permission to only allow owners of profile to view or edit it.
    """
    def has_object_permission(self, request, view, obj):
		# check if user who launched request is object owner 
        if obj.user != request.user: 
            return True
        else:
            return False

    # def has_object_permission(self, request, view, obj):
    #     return obj.user == request.user