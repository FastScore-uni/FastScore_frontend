import 'package:flutter/material.dart';

class SongItem extends StatelessWidget {
  final String date;
  final String title;
  final String duration;
  final String format;
  final Color? color;
  final String? imageUrl;
  final String? imageAsset;
  final bool isSelected;
  final VoidCallback? onTap;

  const SongItem({
    super.key,
    required this.date,
    required this.title,
    required this.duration,
    required this.format,
    this.color,
    this.imageUrl,
    this.imageAsset,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: isSelected
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : null,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Row(
              children: [
                // Avatar/Icon - can be color circle or image
                _buildAvatar(isMobile),
                SizedBox(width: isMobile ? 12 : 16),
                // Song details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: isMobile ? 11 : 12,
                        ),
                      ),
                      SizedBox(height: isMobile ? 2 : 4),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: isMobile ? 14 : 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isMobile ? 2 : 4),
                      Text(
                        "Original song duration: $duration",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: isMobile ? 13 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Format badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 12,
                    vertical: isMobile ? 3 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                  ),
                  child: Text(
                    format,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: isMobile ? 11 : 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar([bool isMobile = false]) {
    final size = isMobile ? 48.0 : 56.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildAvatarContent(),
    );
  }

  Widget? _buildAvatarContent() {
    // Priority: imageAsset > imageUrl > colored circle (null)
    if (imageAsset != null) {
      return Image.asset(
        imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackIcon();
        },
      );
    }
    
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackIcon();
        },
      );
    }
    
    // No image specified, show colored circle (null returns empty content)
    return null;
  }

  Widget _buildFallbackIcon() {
    return const Center(
      child: Icon(
        Icons.music_note,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
