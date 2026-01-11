"""
AI-Enabled Pet Adoption & Care Management System - Permissions
Custom permission classes for role-based access control
"""

from rest_framework import permissions


class IsAdmin(permissions.BasePermission):
    """
    Custom permission to only allow admin users.
    """
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.role == 'admin'
        )


class IsOwnerOrAdmin(permissions.BasePermission):
    """
    Custom permission to allow owners of an object or admin users.
    """
    
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj):
        # Admin can do anything
        if request.user.role == 'admin':
            return True
        
        # Check if user is the owner of the pet post
        if hasattr(obj, 'posted_by'):
            return obj.posted_by == request.user
        
        # Check if user is the owner of the adoption request
        if hasattr(obj, 'user'):
            return obj.user == request.user
        
        return False


class IsAdoptedPetOwner(permissions.BasePermission):
    """
    Permission for users who have adopted the pet.
    """
    
    def has_object_permission(self, request, view, obj):
        if request.user.role == 'admin':
            return True
        
        # For pet-related objects
        if hasattr(obj, 'pet'):
            return obj.pet.current_owner == request.user
        
        # For pet objects directly
        if hasattr(obj, 'current_owner'):
            return obj.current_owner == request.user
        
        return False


class ReadOnly(permissions.BasePermission):
    """
    Read-only permission for safe methods.
    """
    
    def has_permission(self, request, view):
        return request.method in permissions.SAFE_METHODS
